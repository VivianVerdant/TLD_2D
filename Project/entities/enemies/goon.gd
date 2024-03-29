@tool
extends CharacterBody2D

var sleeping = false
var target = position
var hunting = false
@export var target_offset: Vector2
@export var speed = 25

@export var melee_damage: int

@export var initial_health: int
var health

var initial_pos

var layer
var mask

@onready var effects_player = $effects_player
@onready var sprite = $sprite


func _ready():
	layer = collision_layer
	mask = collision_mask
	health = initial_health
	initial_pos = position
	if get_tree().get_nodes_in_group("player").size() > 0:
		target = get_tree().get_nodes_in_group("player")[0]

func _physics_process(_delta):
	if sleeping or effects_player.is_playing() or not hunting or EventManager.paused:
		return
	
	#effects_player.advance(delta)
	
	sprite.scale.x = sprite.scale.x if sign(velocity.x) == sign(sprite.scale.x) else -sprite.scale.x
	
	velocity = global_position.direction_to(target.global_position+target_offset) * speed
	move_and_slide()

func reset():
	sleeping = true
	visible = true
	collision_layer = layer
	collision_mask = mask
	health = initial_health
	position = initial_pos

func hit(damage, giver):
	health -= damage
	var knockback = giver.global_position.direction_to(global_position) * damage * 8.0
	move_and_collide(knockback)
	if health < 0:
		die()
	effects_player.play("hit flash")
	
func die():
	sleeping = true
	visible = false
	collision_layer = 0
	collision_mask = 0


func _on_hitbox_body_entered(body):
	if sleeping:
		return
	if body.has_method("hit"):
		body.hit(melee_damage, self)


func _on_hunt_area_body_entered(entered_body):
	if entered_body is Player:
		hunting = true


func _on_hunt_area_body_exited(body):
	if body is Player:
		hunting = false

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
