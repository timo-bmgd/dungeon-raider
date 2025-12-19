extends Node

enum Level {SPACESHIP, DUNGEON}
var current_level = Level.SPACESHIP

var scenes_path = "res://scenes/%s.tscn"

@onready var ui: CanvasLayer = %ui
@onready var level_container: Node2D = %LevelContainer

var inventory = Array()

var throw_pressed = false
@onready var throw_timer: Timer = $throw_timer

var selected_inv_spot_index := 0:
	set(value):
		selected_inv_spot_index = clamp(value, 0, 4)
		ui.set_select(selected_inv_spot_index)
		
		
func _unhandled_key_input(event: InputEvent) -> void:
	var actions = ["1", "2", "3", "4"]
	for action in actions:
		if event.is_action_pressed(action):
			selected_inv_spot_index = event.as_text().to_int()
	if event.is_action_pressed("throw"):
		throw_pressed = true;
		throw_timer.start()
		print("throw!")
	if event.is_action_released("throw"):
		print("pressed for " + str(4096-throw_timer.time_left))
		throw_timer.timeout.emit()

		
func collect_item(item):
	inventory.append(item)
	print(item)
	ui.add_item(item)

func _ready() -> void:
	# Set the SPACESHIP as the level
	load_level("level_spaceship")
	

func clear_levels():
	for child in level_container.get_children():
		child.queue_free()
		
		
func load_level(scene_name):
	clear_levels()
	var level: Resource = ResourceLoader.load(scenes_path % scene_name)
	level_container.add_child(level.instantiate())


func _on_throw_timer_timeout() -> void:
	# throw the item that you have!
	print("throwing item!")
	print(str(get_viewport().get_mouse_position()))
