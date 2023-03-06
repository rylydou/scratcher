extends Node2D

@export var warn_time := 1.0
@export var speed := 256.0
@export_flags_2d_physics var active_layer: int

@onready var rocket: Sprite2D = $Rocket
@onready var explosion: Area2D = $Explosion
@onready var explosion_sprite: Sprite2D = $Explosion/Sprite
@onready var target: Sprite2D = $Target

func _ready() -> void:
	rocket.position.y = -200
	rocket.position.x = randf_range(-300, 300)
	
	if randi() % 3 == 0:
		target.position = (Globals.player.position - rocket.position) * 3
	else:
		target.position.y = 200
		target.position.x = randf_range(-256, 256)
		
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(rocket.position, target.position, 1)
	query.exclude = [self]
	var result := space.intersect_ray(query)
	if result.size() == 0:
		queue_free()
		return
	target.position = result.position
	
	await wait()
	await drop()
	explode()

func wait() -> void:
	var tween := get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(target, 'modulate:a', .5, warn_time).from(0.)
	tween.parallel().tween_property(target, 'scale', target.scale, warn_time).from(Vector2.ZERO)
	await tween.finished

func drop():
	var tween := get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(rocket, 'position',
		target.position,
		target.position.distance_to(rocket.position) / speed)
	await tween.finished

func explode():
	rocket.hide()
	target.hide()
	
	explosion.collision_layer = active_layer
	explosion.position = rocket.position
	explosion.show()
	
	var color: Color = explosion_sprite.modulate
	explosion_sprite.modulate = Color.WHITE
	
	var tween := get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(explosion_sprite, 'modulate', color, 0).set_delay(0.1)
	tween.tween_callback(func(): explosion.collision_layer = 0)
	tween.tween_property(explosion_sprite, 'modulate:a', 0.0, .2)
	
	await tween.finished
	queue_free()

func _process(delta: float) -> void:
	target.rotation += PI*1*delta
