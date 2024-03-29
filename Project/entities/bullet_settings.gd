class_name BulletSettings
extends Resource

enum COLLISION_TYPE {PLAYER, ENEMIES, WORLD}

@export var dropoff:float
@export var damage:float
@export var speed:float
@export var size:float
@export var color:Color
var owner:Node
@export var initial_position:Vector2
@export var initial_velocity:Vector2
@export var collision_mask: COLLISION_TYPE
