extends Area2D

@export var size := 64.
@export var shape_resolution := 360.
@export var shape_thickness := 0.05

@export var speed_min := 8.
@export var speed_max := 16.
@onready var speed := randf_range(speed_min, speed_max)

func _ready() -> void:
	var dir = -1 if randi()%2 == 0 else 1
	position.x = 400*dir
	position.y = randf_range(100, -100)
	speed *= -dir
	
	var points: PackedVector2Array = []
	points.resize(shape_resolution)
	for i in shape_resolution:
		var point := Vector2.from_angle(float(i)/shape_resolution*PI*2)
		var distance := size/2 - (size*shape_thickness)/2
		point *= distance
		points[i] = point
	
	$Shape.polygon = points
	$Rect.size = Vector2(size, size)
	$Rect.position = Vector2(-size/2, -size/2)

func _physics_process(delta: float) -> void:
	position.x += speed*delta
	
	if position.x > 500 or position.x < -500:
		queue_free()
