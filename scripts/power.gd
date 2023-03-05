extends Area2D

@export var bonus_points := 100

func _ready() -> void:
	position.x = randf_range(-256, 256)
	position.y = randf_range(32, 100)

func _physics_process(delta: float) -> void:
	position.y -= 6*delta
	
	if position.y < -200:
		queue_free()

func _on_body_entered(player: Player) -> void:
	if player.powers >= player.max_power:
		Globals.main.points += bonus_points
	else:
		player.powers += 1
	
	collision_mask = 0
	queue_free()
