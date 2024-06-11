extends Node2D

class_name Actor 

signal initialized (actor: Actor)

@export var animatedSprite2D : AnimatedSprite2D
@export var characterBody2D : CharacterBody2D
@export var movement_speed : float = 1

@export var path_root: String = "Object"

# Called when the node enters the scene tree for the first time.
func _ready():
	animatedSprite2D.play("Idle_Down")

	await get_tree().create_timer(0.01).timeout
	var root = get_tree().root
	var parent = null
	if root.has_node(path_root):
		parent = root.get_node(path_root)
	else:
		parent = Node.new()
		parent.set_name(path_root)
		root.add_child(parent)
		
	self.get_parent().remove_child(self)
		
	parent.add_child(self)
	
	initialized.emit(self)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	

func process_input(input_frame: InputFrame): #movement_input : Vector2):
	process_movement(input_frame.movement)
	

func process_movement(movement_input: Vector2):
	if movement_input == null:
		return
	
	var anim_name = "Idle_"
	if movement_input.x != 0:
		anim_name += "Left"
		animatedSprite2D.flip_h = movement_input.x > 0
		
	if movement_input.y > 0:
		anim_name += "Down"
	elif movement_input.y < 0:
		anim_name += "Up"

	if anim_name == "Idle_":
		return
				
	animatedSprite2D.play(anim_name)
	characterBody2D.velocity = movement_input * movement_speed
	characterBody2D.move_and_slide()
