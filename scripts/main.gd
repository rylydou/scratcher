class_name Main extends Node

@export var player_scene: PackedScene

@onready var world: Node2D = $Game/World
@onready var stage: Node2D = $Game/Stage
# Nodes
@onready var spawner: Node = $Spawner
@onready var spawn_point: Marker2D = $Game/Stage/SpawnPoint
# UI
@onready var start_screen: Control = $UI/StartScreen
@onready var death_screen: Control = $UI/DeathScreen

@onready var background: Node2D = $Background/Score
@onready var postprocess: Node2D = $Postprocess

var ds := DataStore.new('user://store.json', DataStore.Format.TextFile)

var running := false

var highscore: int

var points: int
var start_timestamp: int
var acumulated_time: float

func _enter_tree() -> void:
	Globals.main = self

func _ready() -> void:
	EventBus.player_died.connect(player_died)
	EventBus.game_started.connect(start_game)
	
	ds.load_from_disk()
	highscore = ds.fetch('highscore', 0)
	$Background/Score/Label/ScoreLabel.text = str(highscore)
	
	background.hide()
	death_screen.hide()
	
	postprocess.show()
	start_screen.show()

func _process(delta: float) -> void:
	if not running:
		if Input.is_action_just_pressed('dash'):
			start_game()
	
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if not running: return
	
	acumulated_time += delta
	
	var score := calculate_score()
	
	$Background/Score/Label.text = str(score).pad_zeros(8)
	$Background/Score/Label/TimeLabel.text = time_convert(acumulated_time)
	
	spawner.run(delta)

func time_convert(time_in_sec: float) -> String:
	var fracts := fmod(time_in_sec, 1) * 100
	var seconds := int(time_in_sec)%60
	var minutes := int(time_in_sec)/60
	
	return "%02d:%02d:%02d" % [minutes, seconds, fracts]

func start_game() -> void:
	background.show()
	points = 0
	start_timestamp = Time.get_ticks_msec()
	acumulated_time = 0.
	
	start_screen.hide()
	death_screen.hide()
	
	# Remove everything from the previous game
	for child in world.get_children():
		child.queue_free()
	
	# Spawn the player
	var player = player_scene.instantiate() as Player
	player.position = spawn_point.position
	world.add_child(player)
	
	running = true
	spawner.reset()

func player_died() -> void:
	running = false
	
	var score := calculate_score()
	
	$UI/DeathScreen/ScoreLabel.text = str(score)
	$UI/DeathScreen/ScoreLabel/HighscoreLabel.hide()
	if score > highscore:
		$UI/DeathScreen/ScoreLabel/HighscoreLabel.show()
		highscore = score
		$Background/Score/Label/ScoreLabel.text = str(highscore)
		ds.store('highscore', highscore)
		ds.save_to_disk()
	
	death_screen.show()
	background.hide()

func calculate_score() -> int:
	var score := points
	score += acumulated_time * (2000./60.)
	return score
