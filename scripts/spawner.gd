extends Node

const TPS := 30.0

@export var power: PackedScene
var next_power: float
@export var beam: PackedScene
var next_beam: float
@export var floater: PackedScene
var next_floater: float
@export var rocket: PackedScene
var next_rocket: float
@export var big_floater: PackedScene
var next_big_floater: float

@onready var world: Node = $'../Game/World'

func reset() -> void:
	next_beam = -1.
	next_power = -1.
	next_floater = -1.
	next_rocket = 2.
	next_big_floater = 5.

func run(delta: float) -> void:
	next_power -= delta
	if next_power < 0:
		next_power = randf_range(160/TPS, 240/TPS)
		#next_power = randf_range(30/TPS, 30/TPS)
		spawn(power)
	
	next_beam -= delta
	if next_beam < 0:
		next_beam = randf_range(100/TPS, 140/TPS)
		spawn(beam)
	
	next_floater -= delta
	if next_floater < 0:
		next_floater = randf_range(40/TPS, 60/TPS)
		spawn(floater)
	
	next_big_floater -= delta
	if next_big_floater < 0:
		next_big_floater = randf_range(240/TPS*2, 360/TPS*2)
		spawn(big_floater)
	
	next_rocket -= delta
	if next_rocket < 0:
		next_rocket = randf_range(90/TPS, 120/TPS)
		if randi() % 3 == 0:
			for i in 3:
				spawn(rocket)
		else:
			spawn(rocket)

func spawn(scene: PackedScene) -> void:
	var node := scene.instantiate() as Node2D
	world.add_child(node)
