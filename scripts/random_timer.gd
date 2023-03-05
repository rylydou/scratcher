class_name RandomTimer extends Timer

const TPS := 60.0

@export var min := ''
@onready var min_time := parse(min)
@export var max := ''
@onready var max_time := parse(max)

func _ready() -> void:
	timeout.connect(set_timer)

func set_timer() -> void:
	wait_time = randf_range(min_time, max_time)
	start()

func parse(str: String) -> float:
	if str.ends_with('t'):
		return float(str.substr(0, str.length() - 1))/TPS
	
	if str.ends_with('p'):
		return 1.0/float(str.substr(0, str.length() - 1))
	
	if str.ends_with('s'):
		return float(str.substr(0, str.length() - 1))
	
	return 1.0/0.0 # infinity
