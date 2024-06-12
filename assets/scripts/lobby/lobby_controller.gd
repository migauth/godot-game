extends Node

class_name Lobby

const PASS_KEY = '5ZHlrh4Fmbg2kDtR'
const LOCAL_HOST = 'localhost'

signal on_session_joined
signal on_session_hosted
signal on_game_started

@export_category("Connection Config")
@export var force_local : bool = false
@export var url = LOCAL_HOST
@export var port : int = 8765

@export_category("UI")
@export var ui_scene : PackedScene

var _client : WebSocketClient = null
var _ui = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_client = $WebSocketClient
	
	if _client == null:
		printerr("WebSocketClient is null!")
		return
		
	load_ui()
		
	_connect_to_matchmaking_server()


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


func load_ui():
	_ui = $LobbyUI	
	if _ui != null:
		return
		
	_ui = ui_scene.instantiate()
	
	
func encrypt_password(password: String) -> PackedByteArray:
	var aes = AESContext.new()
	aes.start(AESContext.MODE_ECB_ENCRYPT, PASS_KEY.to_utf8_buffer())
	var pbytes = aes.update(password.to_utf8_buffer())
	aes.finish()
	
	return pbytes
	

#region Client Signals
func _on_websocket_client_connected_to_server():
	var ws = _client.get_socket()
	print("Client connected...")
	
	
func _on_websocket_client_connection_close():
	var ws = _client.get_socket()
	print("Client disconnected with code: %s, reason %s" % [ws.get_close_code(), ws.get_close_reason()])


func _on_websocket_message_received(message: Dictionary):
	print("Message received: %s" % [message])
	
	if not message['op']:
		pass
	
	var op = int(message['op'])
	match(op):
		LobbyReq.OP.GET_GAME_LIST:
			var game_list = $LobbyUI/Join/SessionList/ScrollContainer/Panel/ItemList as ItemList
			game_list.clear()
			for session_name in message['session_names']:
				game_list.add_item(session_name)
			
			return
		_:
			pass
		
	
#endregion


#region Requests
func send_req(req: LobbyReq):
	_client.send(JSON.stringify(req.message))


func test_host():
	host_session("foo")


func host_session(session_name: String, password: String = ""):
	var pbytes = encrypt_password(password)
	var req = LobbyReq.HostSession.new(session_name, pbytes)
	send_req(req)


func join_session(session_name: String, password: String = ""):
	var pbytes = encrypt_password(password)
	var req = LobbyReq.JoinSession.new(session_name, pbytes)
	send_req(req)
	
	
func start_session():
	send_req(LobbyReq.StartSession.new())


func get_game_list():
	send_req(LobbyReq.GetGameList.new())

#endregion	


#region Responses
func _on_session_joined(message):
	pass

#endregion


func _on_click_join_session(index):
	var session_list = $LobbyUI/Join/SessionList/ScrollContainer/Panel/ItemList as ItemList
	if session_list:
		var session_listing = session_list.get_item_text(index) as String
		join_session(session_listing)
