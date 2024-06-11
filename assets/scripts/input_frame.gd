class_name InputFrame

const RELEASED_SHIFT: int = 0
const PRESSED_SHIFT: int = 1
const HELD_SHIFT: int = 2

enum ButtonState {
	RELEASED = 1 << 0,
	PRESSED = 1 << 1,
	HELD = 1 << 2,
}

const MOVE_LEFT: String = "move_left"
const MOVE_RIGHT: String = "move_right"
const MOVE_UP: String = "move_up"
const MOVE_DOWN: String = "move_down"

const A_BUTTON: String = "a_button"
const B_BUTTON: String = "b_button"
const X_BUTTON: String = "x_button"
const Y_BUTTON: String = "y_button"

const L_BUTTON: String = "l_button"
const R_BUTTON: String = "l_button"

const START_BUTTON: String = "start_button"
const SELECT_BUTTON: String = "select_button"

var input: DeviceInput
var movement: Vector2

var a_state: int
var b_state: int
var x_state: int
var y_state: int

var l_state: int
var r_state: int

static func create_frame(input: DeviceInput):
	var new_frame = InputFrame.new()
	new_frame.set_input(input)
	new_frame.calculate_frame()
	
	return new_frame

func set_input(input: DeviceInput):
	self.input = input
	
	
func calculate_frame():
	movement = input.get_vector(MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN)
	
	a_state |= int(input.is_action_just_released(A_BUTTON, true)) << RELEASED_SHIFT
	a_state |= int(input.is_action_just_pressed(A_BUTTON, true)) << PRESSED_SHIFT
	a_state |= int(input.is_action_pressed(A_BUTTON, true)) << HELD_SHIFT
	
	b_state |= int(input.is_action_just_released(B_BUTTON, true)) << RELEASED_SHIFT
	b_state |= int(input.is_action_just_pressed(B_BUTTON, true)) << PRESSED_SHIFT
	b_state |= int(input.is_action_pressed(B_BUTTON, true)) << HELD_SHIFT
	
	x_state |= int(input.is_action_just_released(X_BUTTON, true)) << RELEASED_SHIFT
	x_state |= int(input.is_action_just_pressed(X_BUTTON, true)) << PRESSED_SHIFT
	x_state |= int(input.is_action_pressed(X_BUTTON, true)) << HELD_SHIFT
	
	y_state |= int(input.is_action_just_released(Y_BUTTON, true)) << RELEASED_SHIFT
	y_state |= int(input.is_action_just_pressed(Y_BUTTON, true)) << PRESSED_SHIFT
	y_state |= int(input.is_action_pressed(Y_BUTTON, true)) << HELD_SHIFT
	
	l_state |= int(input.is_action_just_released(L_BUTTON, true)) << RELEASED_SHIFT
	l_state |= int(input.is_action_just_pressed(L_BUTTON, true)) << PRESSED_SHIFT
	l_state |= int(input.is_action_pressed(L_BUTTON, true)) << HELD_SHIFT
	
	r_state |= int(input.is_action_just_released(R_BUTTON, true)) << RELEASED_SHIFT
	r_state |= int(input.is_action_just_pressed(R_BUTTON, true)) << PRESSED_SHIFT
	r_state |= int(input.is_action_pressed(R_BUTTON, true)) << HELD_SHIFT
