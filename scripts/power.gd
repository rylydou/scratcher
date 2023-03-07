extends Area2D

@export var bonus_points := 100

var stop := false

func _ready() -> void:
	position.x = randf_range(-256, 256)
	position.y = randf_range(32, 100)

func _physics_process(delta: float) -> void:
	if stop: return
	
	position.y -= 6*delta
	
	if position.y < -200:
		queue_free()

func _on_body_entered(player: Player) -> void:
	collision_mask = 0
	$Sprite.hide()
	
	if player.powers >= player.max_power:
		Globals.main.points += bonus_points
		stop = true
		
		var label: Label = $Label
		label.position.x = -label.size.x/2
		label.text = '+' + str(bonus_points)
		label.modulate.a = 1.
		
		var t = get_tree().create_tween()
		t.tween_property(self, 'scale', Vector2.ONE, 0.2).from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		await t.finished
		
		t = get_tree().create_tween()
		t.tween_property(label, 'modulate:a', 0., 1.)
		#t.parallel().tween_property(label, 'position:y', label.position.y, 1.)
		await t.finished
	else:
		player.powers += 1
	
	queue_free()
