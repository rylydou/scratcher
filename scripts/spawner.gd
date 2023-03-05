extends Node

const TPS := 30.0

@export var power_scene: PackedScene
var next_power: float
@export var beam_scene: PackedScene
var next_beam: float
@export var floater_scene: PackedScene
var next_floater: float

@onready var world: Node = $'../World'

func reset() -> void:
	next_beam = -1.0
	next_power = -1.0
	next_floater = 1.0

func run(delta: float) -> void:
	next_power -= delta
	if next_power < 0:
		next_power = randf_range(160/TPS, 240/TPS)
		spawn_power()
	
	next_beam -= delta
	if next_beam < 0:
		next_beam = randf_range(100/TPS, 140/TPS)
		spawn_beam()
	
	next_floater -= delta
	if next_floater < 0:
		next_floater = randf_range(40/TPS, 60/TPS)
		spawn_floater()

func spawn(scene: Node2D) -> void:
	var node := scene.instantiate() as Node2D
	world.add_child(node)
