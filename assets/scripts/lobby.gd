extends Node

class_name Lobby

const LOCAL_HOST = 'localhost'

@export var force_local : bool = false
@export var url = LOCAL_HOST
@export var port : int = 8765

var message_to_send = ""
var _client : WebSocketClient = null

func _connect_to_matchmaking_server():
	
	var websocket_url = null
	
	if force_local:
		websocket_url = "%s:%d" % [LOCAL_HOST,port]
	else:
		websocket_url = "%s:%d" % [url,port]
		
	print("Trying to connect to %s" % websocket_url)
	var error = _client.connect_to_url( websocket_url)
	if error != OK:
		print("Error connecting to websocket: ", error)


# Called when the node enters the scene tree for the first time.
func _ready():
	_client = $WebSocketClient
	
	if _client == null:
		printerr("WebSocketClient is null!")
		return
		
	_connect_to_matchmaking_server()


func _on_websocket_message_received(message):
	print("Message received: %s" % [message])


func _on_websocket_client_connection_close():
	var ws = _client.get_socket()
	print("Client disconnected with code: %s, reason %s" % [ws.get_close_code(), ws.get_close_reason()])
	
	
func _on_websocket_client_connected_to_server():
	var ws = _client.get_socket()
	print("Client connected...")
	ping()


func ping():
	await get_tree().create_timer(1)
	_client.send("ping")
