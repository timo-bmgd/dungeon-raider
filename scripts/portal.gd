extends Node2D

@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
enum Destination {LEVEL_SPACESHIP, LEVEL_DUNGEON, LEVEL_HALLWAY}
@export var destination: Destination



func _on_door_body_entered(_body: Node2D) -> void:
	print("portal entered")
	game_manager.load_level(Destination.keys()[destination])
