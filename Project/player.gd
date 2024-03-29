extends CharacterBody2D

@export var MAX_SPEED = 100
@export var ACCELERATION = 5
@export var FRICTION = .25
@export var GRIND_FRICTION = .97
@export var GRAVITY = 10
@export var JUMP_FORCE = 160
@export var JUMP_TIME = .3


var dir = Vector2.ZERO
var jump = false
var jumpTimer = Timer.new()
var interact = false
var carriedObject: RigidBody2D
var carriedObjectLayer

enum States {IDLE, FRONT, DUCK, HURT, FALL, WALK, SLIDE}
var state:States
var busy = false

@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var state_debug = %State

func _ready():
	jumpTimer.set_one_shot(true)
	jumpTimer.set_wait_time(JUMP_TIME)
	add_child(jumpTimer)

func set_state():
	
	if velocity.x == 0 and velocity.y == 0.0:
		state = States.IDLE
		state_debug.text = "Idle"
		return
	
	if is_on_floor():
		if dir.x == 0 and velocity.x != 0:
			state = States.SLIDE
			state_debug.text = "Slide"
			return
		else:
			state = States.WALK
			state_debug.text = "Walk"
			return
	else:
		state = States.FALL
		state_debug.text = "Fall"
		return

func set_sprite():
	if velocity.x != 0 and sign(velocity.x) != sign(sprite.scale.x):
		sprite.scale.x *= -1
	
	match state:
		States.WALK:
			sprite.play("walk", -1, 1.0)
			sprite.speed_scale = abs(velocity.x)/MAX_SPEED
		States.SLIDE:
			sprite.play("walk", -1, 1.0)
			sprite.speed_scale = abs(velocity.x)/MAX_SPEED
		States.IDLE:
			sprite.play("idle", -1, 1.0)
		States.FALL:
			sprite.play("fall", -1, 1.0)
	
func _process(_delta):
	
	dir = -GlobalInput.joyL
	jump = GlobalInput.jump
	
	if not busy:
		set_state()
	
	set_sprite()
	
	velocity.x += dir.x * ACCELERATION
	if abs(velocity.x) > MAX_SPEED:
		velocity.x = dir.x * MAX_SPEED
		
	if state == States.SLIDE:
		velocity.x *= FRICTION
	
	if jump and not state == States.FALL:
			jumpTimer.start()
			velocity.y -= JUMP_FORCE
	
	if is_on_ceiling():
		jumpTimer.stop()

	if not is_on_floor() and not jumpTimer.is_stopped() and dir.y < 0:
		pass
	else:
		velocity.y += GRAVITY
	
	#if abs(velocity.x) < 1 and dir.x == 0:
		#velocity.x = 0
	
	move_and_slide()
