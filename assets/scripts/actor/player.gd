extends Actor

class_name Player

const no_device: int = -2
static var player_device_map = {}

@export var cameraController: CameraController

var device: int = no_device
var input : DeviceInput
var input_frames = Array([], TYPE_OBJECT, &"RefCounted", InputFrame)


# Called when the node enters the scene tree for the first time.
func _ready():
	#input = DeviceInput.new(-1)
	device = -2
	
	for _device in MultiplayerInput.device_actions:
		if player_device_map.has(_device):
			continue
		
		device = _device
		
	if device > -2:
		input = DeviceInput.new(device)
		input_frames.append(InputFrame.create_frame(input))
			
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	super._ready()	


func _unhandled_input(event: InputEvent) -> void:
	try_register_input_device(event)
		
	#if Input.is_action_just_pressed("ui_accept"):
	#	DialogueManager.show_example_dialogue_balloon(load("res://assets/dialogue/test.dialogue"), "this_is_a_node_title")
	#	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if device == no_device or input_frames.size() < 1:
		return
	#if has_device() == false:
	#	return
	
	var f = input_frames[0]
	
	f.calculate_frame()
	#var movement = input.get_vector("move_left", "move_right", "move_up", "move_down")
	#movement *= movement_speed
	process_input(f) # movement)
	
	
func try_register_input_device(event : InputEvent) -> void:
	if device > no_device || player_device_map.has(event.device):
		return
	
	var _device = event.device
	input = DeviceInput.new(_device)
	player_device_map[_device] = self
	device = _device
	
	if input_frames.size() == 0:
		input_frames.append(InputFrame.create_frame(input))
	else:			
		for f in input_frames:
			f.set_device(device)
				

func sig_init_actor(actor: Actor):
	self.actor = actor
		
func _on_joy_connection_changed(_device: int, connected: bool):
	if connected:
		if device < -1 && player_device_map.has(_device) == false:
			input = DeviceInput.new(_device)
			player_device_map[_device] = self
			device = _device
			
			if input_frames.size() == 0:
				input_frames.append(InputFrame.create_frame(input))
			else:			
				for f in input_frames:
					f.set_device(device)
	else:
		if device == _device && player_device_map.has(_device):
			player_device_map.erase(_device)
			device = -2
		
		
func _on_start_pressed(_device: int):
	if device < -1 && player_device_map.has(_device) == false:
		input = DeviceInput.new(_device)
		player_device_map[_device] = self
		device = _device
		

func _on_body_entered_2d(body: Node2D):
	pass
	

func _on_rigid_body_2d_body_entered(body: Node2D):
	pass


func _on_area_2d_entered(area : Area2D):
	pass
