class_name Main extends Node

@export var player_scene: PackedScene

@onready var world: Node = $World
@onready var stage: Node = $Stage
@onready var spawn_point: Marker2D = $Stage/SpawnPoint

@onready var start_screen: Node2D = $UI/StartScreen
@onready var death_screen: Node2D = $UI/DeathScreen

@onready var postprocess: CanvasLayer = $Postprocess

@onready var spawner: Node = $Spawner

var user_can_start_game := true
var running	:= false
func _ready() -> void:
	EventBus.player_died.connect(player_died)
	EventBus.game_started.connect(start_game)
	start_screen.show()
	postprocess.show()

func _process(delta: float) -> void:
	if not running and user_can_start_game:
		if Input.is_action_just_pressed('dash'):
			start_game()
	
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
	
	if running:
		spawner.run(delta) 

func start_game() -> void:
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
	
	death_screen.show()
	
	user_can_start_game = false
	$UI/DeathScreen/PromptLabel.hide()
	
	await get_tree().create_timer(0.5).timeout
	
	user_can_start_game = true
	$UI/DeathScreen/PromptLabel.show()
