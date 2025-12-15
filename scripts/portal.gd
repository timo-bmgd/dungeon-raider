extends Node2D

@onready var game_manager: Node = %GameManager
enum Destination {LEVEL_SPACESHIP, LEVEL_DUNGEON}
@export var destination: Destination

func _on_door_body_entered(body: Node2D) -> void:
	print("portal entered")
	game_manager.load_level(Destination.keys()[destination])
