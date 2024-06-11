extends Actor

class_name Npc

@export var t_amplitude = 0.5

var rng = RandomNumberGenerator.new()
var t = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta * t_amplitude
	
	var movement = Vector2(sin(t) , cos(t)) * movement_speed
	process_movement(movement)


func set_body_position(position : Vector2):
	characterBody2D.position = position


func sig_init_actor(actor: Actor):
	self.actor = actor
