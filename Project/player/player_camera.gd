extends Camera2D

@onready var camera_center = $camera_center

func _physics_process(delta):
	camera_center.global_position = get_screen_center_position()
