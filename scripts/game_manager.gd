extends Node2D

enum Level {SPACESHIP, DUNGEON}
var current_level = Level.SPACESHIP

var scenes_path = "res://scenes/%s.tscn"

@onready var ui: CanvasLayer = %ui
@onready var level_container: Node2D = %LevelContainer
@onready var player: CharacterBody2D = $"../Player"
@onready var item_container: Node2D = $"../ItemContainer"

var inventory = Array()

var throw_pressed = false
@onready var throw_timer: Timer = $throw_timer

signal item_thrown

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

func remove_selected_item() -> Item:
	var item : Item = inventory.pop_at(selected_inv_spot_index)
	if item == null:
		return null
	if item.get_parent():
		item.get_parent().remove_child(item)
	return item

func _on_throw_timer_timeout() -> void:
	var item := remove_selected_item()
	if item == null:
		return
		
	# throw the item that you have!
	var target := get_global_mouse_position() - player.global_position
	item_container.add_child(item)
	item.global_position = player.global_position
	item.linear_velocity = target * 3
	
	# Call directly on THIS item, not via signal
	item.on_thrown()


	
	
