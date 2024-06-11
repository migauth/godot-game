extends Node

class_name CameraController

@export var target: Node2D
@export var camera: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target == null:
		return
	
	camera.position = target.global_position

func set_bounds(camera_bounds: CameraBounds):
	camera.limit_left = camera_bounds.left
	camera.limit_top = camera_bounds.top
	camera.limit_right = camera_bounds.right
	camera.limit_bottom = camera_bounds.bottom
