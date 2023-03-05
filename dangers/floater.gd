extends Area2D

@export var speed_min := 8.0
@export var speed_max := 16.0
@onready var speed := randf_range(speed_min, speed_max)

@export var spin_speed_min := 4.0
@export var spin_speed_max := 4.0
@onready var spin_speed := randf_range(spin_speed_min, spin_speed_max) * (-1 if randi() % 2 == 0 else 1)

@export var sprite_frames := 6

@onready var art: Sprite2D = $Sprite

func _ready() -> void:
	art.frame = randi_range(0, sprite_frames - 1)
	
	var dir = -1 if randi() % 2 == 0 else 1
	position.x = 400 * dir
	position.y = randf_range(100, -100)
	speed *= -dir

func _physics_process(delta: float) -> void:
	position.x += speed * delta
	art.rotation += spin_speed * 2 * PI * delta
	
	if position.x > 500 or position.x < -500:
		queue_free()
