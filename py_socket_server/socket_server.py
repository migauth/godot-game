import argparse
import asyncio
import json
import signal
import socket
import websockets


LOCAL_HOST = "localhost"
PORT = 80

# Define ops
OP_POST_GAME = 1
OP_GAME_FULL = 2
OP_START_CONFIRMATION = 3
OP_JOIN_GAME = 4
OP_START_RECEIVED = 5
OP_QUIT_SESSION = 6
OP_DISBAND_SESSION = 7
OP_GET_GAME_LIST = 8

# Define a dictionary of lambdas keyed by ops
op_handlers = {
    OP_POST_GAME: lambda ws, data: on_game_posted(ws, data),
    OP_START_CONFIRMATION: lambda ws, data: on_start_confirmation(ws),
    OP_JOIN_GAME: lambda ws, data: on_join_game(ws, data),
    OP_START_RECEIVED: lambda ws, data: on_start_received(ws),
    OP_QUIT_SESSION: lambda ws, data: on_quit_received(ws, data),
    OP_DISBAND_SESSION: lambda ws, data: on_disband_received(ws),
    OP_GET_GAME_LIST: lambda ws, data: on_get_game_list(ws),
}

# Define a simple game session data structure
class GameSession:
    def __init__(self, host_ip, session_name, host_ws):
        self.host_ip = host_ip
        self.session_name = session_name
        self.host_ws = host_ws
        self.client_ws = {}  # Set to store client WebSockets

    def add_client(self, client_ws):
        self.client_ws[client_ws.remote_address] = client_ws

    def remove_client(self, client_ws):
        if self.client_ws.__contains__(client_ws.remote_address):
            self.client_ws.remove(client_ws.remote_address)

    async def broadcast_message(self, message):
        for ws in self.client_ws.values():
            await ws.send(message)

    async def notify_host(self, message):
        await self.host_ws.send(message)

    async def notify_client(self, target_UUID, message):
        if self.client_ws.__contains__(target_UUID):
            self.client_ws[target_UUID].send(message)

# Define a dictionary to store game sessions
game_sessions = {}
server = None


async def handle_message(websocket, message):
    print("Got message: `{0}`".format(message))

    try:
        data = json.loads(message)
        op = data.get('op')

        _handler = op_handlers.get(op)
        if _handler:
            await _handler(websocket, data)
        else:
            print("Unknown op:", op)

    except Exception as e:
        print("Got malformed message: {0}".format(e))


async def on_game_posted(websocket, data):
    session_name = data.get('session_name')
    game_session = GameSession(websocket.remote_address, session_name, websocket)
    game_sessions[session_name] = game_session
    print(f"Game session '{session_name}' posted by {websocket.remote_address}.")


async def on_start_confirmation(websocket):
    # Find the game session for this host
    for game_session in game_sessions.values():
        if game_session.host_ws == websocket:
            # Send start message to all members of the game session
            await game_session.broadcast_message(json.dumps({"op": OP_START_CONFIRMATION, "message": "Start"}))
            print(f"Start message sent to all members of game session '{game_session.session_name}'.")
            break


async def on_join_game(websocket, data):
    session_name = data.get('session_name')
    # Find the game session with the given name
    game_session = game_sessions.get(session_name)
    if game_session:
        game_session.add_client(websocket)
        print(f"Player {websocket.remote_address} joined game session '{session_name}'.")
        # Notify all members of the game session about the new player
        await game_session.broadcast_message(json.dumps({"op": OP_JOIN_GAME, "message": f"Player {websocket.remote_address} joined the game."}))
    else:
        print(f"Game session '{session_name}' not found.")


async def on_start_received(websocket):
    # Close WebSocket after receiving start confirmation
    await websocket.close()
    print(f"Player {websocket.remote_address} received start confirmation. Closing their connection.")


async def on_quit_received(websocket, data):
    session_name = data.get('session_name')
    if session_name is not None and game_sessions.__contains__(session_name):
        game_session = game_sessions[session_name]
        game_session.remove_client(websocket)
        await game_session.broadcast_message(json.dumps({"op": OP_QUIT_SESSION, "player": websocket.UUID}))


async def on_disband_received(websocket):
    for session_name, game_session in list(game_sessions.items()):
        if game_session.host_ws == websocket:
            await game_session.broadcast_message(json.dumps({"op": OP_DISBAND_SESSION}))
            del game_sessions[session_name]
            print(f"Game session '{session_name}' removed as host {websocket.remote_address} disconnected.")


async def on_get_game_list(websocket):
    print(f"Getting session list for {websocket.remote_address}")
    await websocket.send(json.dumps({"op": OP_GET_GAME_LIST, "session_names": list(game_sessions.keys())}))


async def handler(websocket, path):
    print(f"New connection: {websocket.remote_address}")
    try:
        async for message in websocket:
            await handle_message(websocket, message)
    except OSError as e:
        print("OSError occurred:", e)
    except ConnectionResetError:
        # Handle connection reset error gracefully
        print("Connection closed unexpectedly.")
    except websockets.exceptions.ConnectionClosedError as e:
        # Handle websockets connection closed error gracefully
        print("Connection closed unexpectedly:", e)
    finally:
        # Remove game session if the host disconnects
        await on_disband_received(websocket)
        print(f"Connection closed: {websocket.remote_address}")


def get_external_ip():
    try:
        # Get the hostname of the machine
        hostname = socket.gethostname()
        # Get the IP address corresponding to the hostname
        ip_address = socket.gethostbyname(hostname)
        return ip_address
    except socket.error as e:
        print("Error retrieving IP address:", e)
        return None


async def main(args):
    global server
    # Example usage

    ip = args.ip
    if ip is None:
        if args.local:
            ip = LOCAL_HOST
        else:
            ip = get_external_ip()
            if ip:
                print("External IP address:", ip)
            else:
                ip = LOCAL_HOST
                print("Failed to get external IP address, falling back to {0}.".format(LOCAL_HOST))

    try:
        server = await websockets.serve(handler, ip, args.port)
        print("Starting server on {0}:{1}".format(ip, args.port))
        # Keep the event loop running indefinitely
        await server.wait_closed()
    except OSError as e:
        # Handle port closure gracefully
        print("Failed to start server on port {0}: {1}".format(args.port, e))
        if 'server' in locals():
            server.close()
            await server.wait_closed()


def handle_signal(signum, frame):
    global server
    print(f"Received signal {signum}, shutting down...")
    if server is not None:
        if server.is_serving():
            server.close()
    else:
        raise KeyboardInterrupt()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Start the server with an optional port argument.")
    parser.add_argument("--port", type=int, default=PORT, help="Port number to listen on (default: 8765)")
    parser.add_argument("--local", action="store_true", help="Run the server as localhost (default: False)")
    parser.add_argument("--ip", type=str, default=None, help="Optional ip, (Default: None)")
    args = parser.parse_args()

    signal.signal(signal.SIGINT, handle_signal)
    signal.signal(signal.SIGTERM, handle_signal)

    # Call the main function with the specified port
    asyncio.run(main(args))
