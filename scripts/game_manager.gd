extends Node

enum Level {SPACESHIP, DUNGEON}
var current_level = Level.SPACESHIP

var scenes_path = "res://scenes/%s.tscn"

@onready var ui: CanvasLayer = %ui
@onready var level_container: Node2D = %LevelContainer


var inventory = Array()

func collect_item(item):
	inventory.append(item)
	print(item)
	ui.add_item(item)

func _ready() -> void:
	# Set the SPACESHIP as the level
	load_level("level_dungeon")
	

func clear_levels():
	for child in level_container.get_children():
		child.queue_free()
		
		
func load_level(scene_name):
	clear_levels()
	var level: Resource = ResourceLoader.load(scenes_path % scene_name)
	level_container.add_child(level.instantiate())
