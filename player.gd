class_name Player extends CharacterBody2D

signal entered_level(level: Node2D);

const TPS = 60.0

@export_group('Platformer State')

@export_subgroup('Movement')
@export var move_max := 36.
#@export_category('Ground')
@export var move_acc_ticks := 3.
@onready var move_acc_time := move_acc_ticks / TPS
@export var move_dec_ticks := 4.
@onready var move_dec_time := move_dec_ticks / TPS
@export var move_opp_ticks := 2.0
@onready var move_opp_time := move_opp_ticks / TPS
#@export_category('Air')
@export var move_acc_air_ticks := 6.0
@onready var move_acc_air_time := move_acc_air_ticks / TPS
@export var move_dec_air_ticks := 8.0
@onready var move_dec_air_time := move_dec_air_ticks / TPS
@export var move_opp_air_ticks := 4.0
@onready var move_opp_air_time := move_opp_air_ticks / TPS

@export_subgroup('Jump')
@export var jump_ticks := 35
@onready var jump_time := jump_ticks / TPS
@export var jump_height := 18.0
@export var extra_fall_mult := 1.5
@export var max_fall_speed_ratio := 1.5
var is_jumping := false

@onready var gravity := calculate_gravity_for_jump(jump_height, jump_time)

@export_subgroup('Assits')
@export var coyote_time_ticks := 6
var coyote_timer := -1.0
@export var jump_buffer_ticks := 6
var jump_buffer_timer := -1.0
@export var max_bonknuge_distance := 4.0

@export_subgroup('Dash')
@export var dash_distance := 32.0
@export var dash_ticks := 12.0
@onready var dash_time := dash_ticks / TPS
var dash_timer := 0.0
var can_dash := false

@export_group('Power')
@export var max_power := 3
@export var power_for_inv := 2
@export var power_inv_frames := 60.0
@export var power_init_lag := 5
@export var power_btw_lag := 5

@export_group('Animation')
@export var air_turn_speed := 180.0

@onready var art_node: Node2D = $Art
@onready var dash_line: Line2D = $DashLine
@onready var trail: Node2D = $Trail

var powers := 0

func _enter_tree() -> void:
	#if is_instance_valid(Globals.player):
	#	push_error('A player already exists somehow!')
	Globals.player = self

func _ready() -> void:
	$AnimationPlayer.play('RESET')
	
	reset_movement()
	
	var base := trail.get_child(0) as Sprite2D
	for index in max_power - 1:
		var clone := base.duplicate() as Sprite2D
		trail.add_child(clone)

var history: Array[Vector2] = []
func _process(delta: float) -> void:
	process_inputs()
	
	if inv_timer > 0.0:
		art_node.modulate.a = randi_range(0,1)
	else:
		art_node.modulate.a = 1.0
	
	var hisotry_size := history.size()
	for index in $Trail.get_child_count():
		var c: Sprite2D = $Trail.get_child(index)
		
		c.visible = index < powers
		var sample_index := power_init_lag + (power_btw_lag*index)
		if hisotry_size > sample_index:
			c.position = c.position.move_toward(history[sample_index], (dash_distance/dash_time)*delta)
	
	art_node.rotation += deg_to_rad(air_turn_speed)*(speed_move/move_max)*delta
	if is_on_floor():
		art_node.rotation = 0.

func reset_movement() -> void:
	speed_move = 0.0
	speed_extra = 0.0
	speed_vertical = 0.0
	
	is_jumping = false
	
	can_dash = true
	dash_timer = 0.0

var input_move := 0.0
var input_jump := false
var input_jump_press := false
var input_dash_press := false
func process_inputs() -> void:
	input_move = Input.get_axis('move_left', 'move_right')
	
	input_jump = Input.is_action_pressed('jump')
	if Input.is_action_just_pressed('jump'):
		input_jump_press = true
	
	if Input.is_action_just_pressed('dash'):
		input_dash_press = true

var speed_move := 0.0
var speed_extra := 0.0
var speed_vertical := 0.0
var facing_direction := 1.0
func _physics_process(delta: float) -> void:
	if input_move != 0 and dash_timer <= 0:
		facing_direction = sign(input_move)
	
	history.push_front(position)
	if history.size() > 60:
		history.pop_back()
	
	inv_timer -= delta
	if position.y > 200:
		hurt()
	
	if dash_timer > 0.0:
		process_state_dash(delta)
	else:
		process_state_platformer(delta)
	
	input_jump_press = false
	input_dash_press = false

func process_state_dash(delta: float) -> void:
	dash_timer -= delta
	if dash_timer < 0:
		position.x += facing_direction * dash_distance

func process_state_platformer(delta: float) -> void:
	if is_on_floor():
		can_dash = true
		is_jumping = false
	
	process_movement(delta)
	process_gravity(delta)
	process_jump(delta)
	
	move()
	
	process_dash(delta)

func process_movement(delta: float) -> void:
	var is_grounded := is_on_floor()
	var is_input_opposing = speed_move != 0.0 and sign(speed_move) != sign(input_move)
	
	var speed := 0.0
	if is_grounded: # grounded movement
		if input_move != 0.0:
			if is_input_opposing: # opposing movement
				speed = move_max / (move_opp_time / delta)
			else:
				speed = move_max / (move_acc_time / delta)
		else:
			speed_move = move_toward(speed_move, 0, move_max / (move_dec_time / delta))
	else: # air movement
		if input_move != 0.0:
			if is_input_opposing: # opposing movement
				speed = move_max / (move_opp_air_time / delta)
			else:
				speed = move_max / (move_acc_air_time / delta)
		else:
			speed_move = move_toward(speed_move, 0, move_max / (move_dec_air_time / delta))
	
	speed_move += input_move * speed
	speed_move = clamp(speed_move, -move_max, move_max)
	
	var hit_wall_on_left := is_on_wall() and test_move(transform, Vector2.LEFT)
	var hit_wall_on_right := is_on_wall() and test_move(transform, Vector2.RIGHT)
	
	if hit_wall_on_left:
		if speed_move < 0.:
			speed_move = -1.
		if speed_extra < 0.: 
			speed_extra = 0.
	
	if hit_wall_on_right:
		if speed_move > 0.:
			speed_move = 1.
		if speed_extra > 0.: 
			speed_extra = 0.

func process_gravity(delta: float) -> void:
	if is_on_ceiling():
		if !try_bonknudge(max_bonknuge_distance*facing_direction):
			if speed_vertical < 0.: speed_vertical = 0.
	
	if is_on_floor():
		if speed_vertical > 0.:
			speed_vertical = 0.
	else:
		speed_vertical += gravity*(1.0 if input_jump else extra_fall_mult)*delta
	
	var max_fall_speed := calculate_jump_velocity(jump_height) * max_fall_speed_ratio
	if speed_vertical > max_fall_speed:
		speed_vertical = max_fall_speed

func try_bonknudge(distance: float) -> bool:
	var x := 0.
	while x != distance:
		if !test_move(transform.translated(Vector2(x, 0.)), Vector2.UP):
			position.x += x
			return true
		x = move_toward(x, distance, 1)
	return false

func process_jump(delta: float) -> void:
	coyote_timer -= delta
	if is_on_floor():
		coyote_timer = coyote_time_ticks / TPS
	
	jump_buffer_timer -= delta
	if input_jump_press:
		jump_buffer_timer = jump_buffer_ticks / TPS
	
	if (coyote_timer > 0. or powers > 0) and jump_buffer_timer > 0.:
		if coyote_timer <= 0.:
			powers -= 1
		
		is_jumping = true
		input_jump_press = false
		coyote_timer = 0.
		jump_buffer_timer = 0.
		
		var jump_velocity := calculate_jump_velocity(jump_height)
		speed_vertical = -jump_velocity

var dash_line_tween: Tween
func process_dash(delta: float) -> void:
	if (can_dash or powers > 0) and input_dash_press:
		if not can_dash:
			powers -= 1
		
		speed_move = 0.
		speed_extra = 0.
		speed_vertical = 0.
		can_dash = false
		dash_timer = dash_time
		
		dash_line.modulate.a = 1.
		dash_line.points[0] = position
		dash_line.points[1] = position
		
		if dash_line_tween:
			dash_line_tween.kill()
		dash_line_tween = get_tree().create_tween()
		dash_line_tween.tween_method(
			func(x): dash_line.points[1].x = x,
			position.x,
			position.x + facing_direction*dash_distance,
			dash_time)
		dash_line_tween.tween_property(dash_line, 'modulate:a', 0., 5/TPS)
		$TeleportSFX.play()

func move() -> void:
	velocity.x = speed_move + speed_extra
	velocity.y = speed_vertical
	
	move_and_slide()

func calculate_gravity_for_jump(height: float, duration: float) -> float:
	return 8.*(height/pow(duration, 2.))

func calculate_jump_velocity(height: float) -> float:
	return sqrt(2*gravity*height)

func hurt() -> void:
	if is_dead: return
	if inv_timer > 0:
		return
	
	$AnimationPlayer.play('death')
	$DeathFX.position = position
	
	if powers >= power_for_inv:
		# consume all the power, either 2 or 1
		powers = 0
		inv_timer = power_inv_frames/TPS
		
		if position.y > 144.:
			position = Vector2.ZERO
		
		return
	
	die()

var is_dead := false
func die() -> void:
	if is_dead: return
	is_dead = true
	
	EventBus.player_died.emit()
	art_node.hide()
	trail.hide()
	dash_line.hide()
	set_process(false)
	set_physics_process(false)
	$DeathSFX.play()

var inv_timer:= 0.
func _on_hurtbox_area_area_entered(area: Area2D) -> void:
	hurt()
