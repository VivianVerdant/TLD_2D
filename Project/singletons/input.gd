extends Node

var joyLX = 0
var joyLY = 0
var joyRX = 0
var joyRY = 0

var joyL = Vector2.ZERO
var joyR = Vector2.ZERO

var action:bool
var jump:bool

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#OS.current_screen = 1
	#OS.window_maximized = true
	pass

func _input(event):
	if event == InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	action = Input.is_action_pressed("Action")
	jump = Input.is_action_pressed("Jump")
	
	joyLX = Input.get_action_strength("MoveX+") - Input.get_action_strength("MoveX-")
	joyLY = Input.get_action_strength("MoveY+") - Input.get_action_strength("MoveY-")
	
	joyRX = Input.get_action_strength("LookX+") - Input.get_action_strength("LookX-")
	joyRY = Input.get_action_strength("LookY+") - Input.get_action_strength("LookY-")
	
	joyL = Vector2(joyLX,joyLY)
	joyR = Vector2(joyRX,joyRY)

	if Input.is_action_just_released("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
