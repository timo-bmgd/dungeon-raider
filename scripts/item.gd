class_name Item
extends Area2D

@onready var game_manager: Node = %GameManager
var in_inventory = false

func _on_body_entered(body: Node2D) -> void:
	print("hot!")
	game_manager.collect_item(self)
