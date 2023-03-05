class_name Hurtbox extends Node

signal hit()

func hurt() -> void:
	hit.emit()
