extends Area2D

@export var speed_min := 8.0
@export var speed_max := 16.0
@onready var speed := randf_range(speed_min, speed_max)

func _ready() -> void:
	var dir = -1 if randi()%2 == 0 else 1
	position.x = 400*dir
	position.y = randf_range(100, -100)
	speed *= -dir
	
	return
	
	var shape: CollisionPolygon2D = $Shape
	for i in 360:
		var point := Vector2.from_angle(deg_to_rad(i))
		point *= 32.
		shape.polygon.append(point)

func _physics_process(delta: float) -> void:
	position.x += speed*delta
	
	if position.x > 500 or position.x < -500:
		queue_free()
