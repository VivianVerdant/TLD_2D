@tool
class_name Player
extends CharacterBody2D

@export var MAX_SPEED: float = 150.0
@export var ACCELERATION: float = 15.0
@export var AIR_FRICTION: float = 0.5
@export var SKID_FRICTION: float = 0.5
@export var SLIDE_FRICTION: float = 0.5
@export var FRICTION: float = 0.5
@export var GRAVITY: float = 8.0
@export var JUMP_FORCE: float = 175.0
@export var GROUND_ANGLE: float = 45.0

@export var bullet_settings = Array()
@onready var bullet_timer: Timer = $bullet_timer
@onready var bullet:PackedScene = preload("res://entities/bullet.tscn")
var can_shoot: bool = false

@export var melee_damage: int = 10

@export var max_health: int
var curr_health: int
@onready var hit_timer = $hit_timer

var motion: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT
@onready var jump_timer: Timer = $jump_timer
var jumping: bool = false
var jump_pressed_prev_frame: bool = false
var snap: Vector2 = Vector2.ZERO
var on_ground: bool = false
var collision_angle: Vector2

enum PLATFORMER_STATES {NEUTRAL, SLIDING, RUNNING, FALLING, JUMPING, SKIDDING}
var platformer_state: PLATFORMER_STATES = PLATFORMER_STATES.FALLING

enum ACTION_STATES {MELEE}
var action_state: ACTION_STATES

var busy: bool = false
var no_grav: bool = false


@onready var body = $flip/body
@onready var flip = $flip
@onready var animation_player = $animation_player
@onready var audio_player = $audio_stream_player
@onready var effects_player = $effects_player

@onready var debug_labels = %Debug_Labels

signal ui_update_health(value)
signal ui_update_energy(value)

func _ready():
	can_shoot = true
	curr_health = max_health

func set_platformer_state():
	
	platformer_state = PLATFORMER_STATES.NEUTRAL
	
	var is_jump_just_pressed = (true if GlobalInput.jump and not jump_pressed_prev_frame else false)
	jump_pressed_prev_frame = GlobalInput.jump
	
	# Start jumping
	if is_jump_just_pressed and is_on_floor():
		platformer_state = PLATFORMER_STATES.JUMPING			# Set state
		jumping = true
		jump_timer.start()
		return
	
	# Ground movement
	if is_on_floor():
		if GlobalInput.joyLY > 0:
			platformer_state = PLATFORMER_STATES.SLIDING	# Set state
			return
		
		if abs(GlobalInput.joyLX) < 0.01:
			platformer_state = PLATFORMER_STATES.NEUTRAL	# Set state
			return
		
		if sign(GlobalInput.joyLX) == sign(velocity.x):
			platformer_state = PLATFORMER_STATES.RUNNING	# Set state
			return

		platformer_state = PLATFORMER_STATES.SKIDDING	# Set state
		return

	else:
		# Air movement
		if jumping and GlobalInput.jump:
			platformer_state = PLATFORMER_STATES.JUMPING			# Set state
			return
		else:
			platformer_state = PLATFORMER_STATES.FALLING			# Set state
			jumping = false
			return

func set_animation(delta):
	
	animation_player.advance(delta)
	#effects_player.advance(delta)
	
	if sign(GlobalInput.joyLX) != 0:
		flip.scale.x = sign(GlobalInput.joyLX)
		
	#if GlobalInput.joyL != Vector2.ZERO:
		#facing = GlobalInput.joyL

	match platformer_state:
		PLATFORMER_STATES.NEUTRAL:
			animation_player.play("stand", -1, 0.0)
		PLATFORMER_STATES.JUMPING:
			animation_player.play("jump", -1, 0.0)
			animation_player.seek(0.0433, true)
		PLATFORMER_STATES.FALLING:
			animation_player.play("jump", -1, 0.0)
			animation_player.seek(0.0167, true)
		PLATFORMER_STATES.RUNNING, PLATFORMER_STATES.SLIDING:
			animation_player.play("run", -1, abs(velocity.x) / MAX_SPEED)
		
		#PLATFORMER_STATES.MELEE:
			#if not busy and is_on_floor():
				#animation_player.play("melee ground", -1, 1.0)
				#return
			#elif not busy and not is_on_floor():
				#animation_player.play("melee air", -1, 1.0)
				#return
			#var f = animation_player.current_animation_position
			#if f == animation_player.current_animation_length:
				#state = PLATFORMER_STATES.STANDING
				#busy = false
				#return
			#if is_on_floor():
				#animation_player.play("melee ground", -1, 1.0)
				#animation_player.seek(f, true)
			#else:
				#animation_player.play("melee air", -1, 1.0)
				#animation_player.seek(f, true)

func do_physics():
	
	# TODO: refactor head bonkin stuff
	# TODO: refactor jump_timer stuff
	# TODO: cap player speed
	
	match platformer_state:
		PLATFORMER_STATES.JUMPING:
			on_ground = false
			velocity.x += GlobalInput.joyLX * AIR_FRICTION * ACCELERATION
			
		PLATFORMER_STATES.FALLING:
			on_ground = false
			velocity.y += GRAVITY
			velocity.x += GlobalInput.joyLX * AIR_FRICTION * ACCELERATION
			
		PLATFORMER_STATES.RUNNING:
			on_ground = true
			velocity.x += GlobalInput.joyLX * ACCELERATION
			
		PLATFORMER_STATES.SKIDDING:
			on_ground = true
			velocity.x += GlobalInput.joyLX * SKID_FRICTION * ACCELERATION
			
		PLATFORMER_STATES.SLIDING:
			on_ground = true
			velocity.x *= SLIDE_FRICTION
			
		PLATFORMER_STATES.NEUTRAL, _:
			on_ground = true
			velocity.x *= FRICTION
	
	# bonk head on ceilings
	if is_on_ceiling():
		print("bonk")
		velocity.y = max(velocity.y,0)
		jump_timer.stop()
	
	# I don't remember what this code does XD
	#if not jump_timer.is_stopped() and GlobalInput.jump:
		#snap = Vector2.ZERO
	#else:
		#if not no_grav:
			#velocity.y += GRAVITY
		#snap = Vector2(0,4)
	
	# fully stop to zero if small enough
	#if abs(velocity.x) < .01 and GlobalInput.joyLX == 0:
		#velocity.x = 0
	
	# apply velocity using class function
	
	#on_ground = is_on_floor()
	
	move_and_slide()
	# kill x velocity if we ran into a wall
	#for i in get_slide_collision_count():
		#var collision: KinematicCollision2D = get_slide_collision(i)
		#if abs(collision.get_normal().y) <= .1:
			#velocity.x = 0

func do_actions():
	if GlobalInput.action and not busy:
		#print("paunch")
		#state = PLATFORMER_STATES.MELEE
		pass

func _physics_process(delta):
	if Engine.is_editor_hint() or EventManager.paused:
		return
	
	if not busy:
		set_platformer_state()
		do_physics()
		#set_action_state()
		do_actions()
		set_animation(delta)
	
	if on_ground:
		pass
	
	debug_labels.update_data({
		"State": PLATFORMER_STATES.keys()[platformer_state],
		"On Ground": on_ground,
		"Velocity": velocity
	})

func _on_hitbox_body_entered(object):
	if object.has_method("hit"):
		object.hit(melee_damage, self)

func _on_hitbox_area_entered(area):
	if area.has_method("hit"):
		print(area)
		area.hit(melee_damage, self)

func hit(damage, giver):
	if hit_timer.is_stopped():
		curr_health -= damage
		
		print(str(curr_health) + ":" + str(max_health))
		emit_signal("ui_update_health", (curr_health as float)/(max_health as float))
		effects_player.play("hit flash")
		hit_timer.start()
		var knockback = giver.global_position.direction_to(global_position) * damage * 16.0
		velocity.x = knockback.x
		velocity.y = knockback.y
		move_and_collide(knockback)
		snap = Vector2.ZERO
		
		if curr_health <= 0:
			die()

func die():
	EventManager.emit_signal("player_death")
	#queue_free()

func fire():
	var b = bullet.instance()
	b.start(global_position, facing, bullet_settings[0])
	get_parent().add_child(b)

func drop():
	var col = move_and_collide(Vector2.DOWN, true, true, true)
	
	if col.get_collider().collision_layer >> 4:
		print(col.collider.collision_layer >> 4)
		position.y += 1
		jumping = false

func _notification(what):
	if not Engine.is_editor_hint():
		return
	
	match what:
		2000:
			move_snap()
		_:
			pass

func move_snap():
	global_position.x = floor(global_position.x / 16) * 16
	global_position.y = floor(global_position.y / 16) * 16

func _on_effects_player_animation_finished(anim_name):
	if anim_name == "hit_flash":
		effects_player.play("none")
