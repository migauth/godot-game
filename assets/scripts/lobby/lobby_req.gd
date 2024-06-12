class_name LobbyReq

enum OP {
	POST_GAME = 1,
	GAME_FULL = 2,
	START_CONFIRMATION = 3,
	JOIN_GAME = 4,
	START_RECEIVED = 5,
	QUIT_SESSION = 6,
	DISBAND_SESSION = 7,
	GET_GAME_LIST = 8,
}

var message: Dictionary
	
class JoinSession:
	extends LobbyReq
	
	func _init(session_name: String, password: PackedByteArray) -> void:
		self.message = {
			'op': OP.JOIN_GAME,
		 	'session_name': session_name,
		}
		
		if password.size() > 0:
			self.message['password'] = password.get_string_from_ascii()


class HostSession:
	extends LobbyReq
	
	func _init(session_name: String, password: PackedByteArray) -> void:
		self.message = {
			'op': OP.POST_GAME,
		 	'session_name': session_name,
		}
		
		if password.size() > 0:
			self.message['password'] = password.get_string_from_ascii()
		
		
class StartSession:
	extends LobbyReq
	
	func _init() -> void:
		self.message = {
			'op': OP.START_CONFIRMATION
		}

class GetGameList:
	extends LobbyReq
	
	func _init() -> void:
		self.message = {
			'op': OP.GET_GAME_LIST
		}
