extends Area2D

@export var warn_time := 1.
@export var start_delay := 1.
@export_flags_2d_physics var active_layer: int

@export_group('Tilt')
@export var tilt_min := .05
@export var tilt_max := .15
@export var tilt_time := 1.

@export_group('Move')
@export var move_distance_min := 32.
@export var move_distance_max := 128.
@export var move_time := 2.

@export_group('Stay')
@export var stay_rate_amplitude := .1
@export var stay_wave_rate := 6.
@export var stay_time := 5.

func _ready() -> void:
	position.x = randf_range(-300, 300)
	
	await fade_in()
	
	if randi() % 3 == 0:
		await do_move()
	elif randi() % 3 == 0:
		await do_tilt()
	else:
		await do_stay()
	
	await fade_out()
	queue_free()

func fade_in() -> void:
	modulate.a = 0.
	
	var tween := get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, 'modulate:a', .5, warn_time)
	
	await tween.finished
	collision_layer = active_layer
	modulate.a = 1.
	
	await get_tree().create_timer(start_delay).timeout

func fade_out() -> void:
	collision_layer = 0
	modulate.a = 1.
	var tween := get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, 'modulate:a', 0, 1.)
	
	await tween.finished

func do_tilt() -> void:
	var tween := get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, 'rotation',
		deg_to_rad(randf_range(tilt_min, tilt_max)) *(-1 if randi()%2 == 0 else 1),
		tilt_time)
	
	await tween.finished

func do_move() -> void:
	var tween := get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, 'position:x',
		position.x + randf_range(move_distance_min, move_distance_max)*(-1 if randi()%2 == 0 else 1),
		move_time)
	
	await tween.finished

func do_stay() -> void:
	await get_tree().create_timer(stay_time).timeout
