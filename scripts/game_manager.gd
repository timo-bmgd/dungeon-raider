# game_manager.gd - Orchestrates gameplay, delegates to inventory

extends Node2D

enum Level {SPACESHIP, DUNGEON}

var current_level = Level.SPACESHIP
var scenes_path = "res://scenes/%s.tscn"

@onready var ui: CanvasLayer = %ui
@onready var level_container: Node2D = %LevelContainer
@onready var player: CharacterBody2D = $"../Player"
@onready var item_container: Node2D = $"../ItemContainer"
@onready var inventory: Node = $"../Player/Inventory"
@onready var throw_timer: Timer = $throw_timer


func _ready() -> void:
	# Connect UI to inventory
	ui.connect_to_inventory(inventory)
	
	# Set the SPACESHIP as the level
	load_level("level_spaceship")
	
	
func _input(event: InputEvent) -> void:
	# Handle scrolling
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var current = inventory.get_selected_slot()
				var new_index = (current - 1) % 4
				inventory.set_selected(new_index)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var current = inventory.get_selected_slot()
				var new_index = (current + 1) % 4
				inventory.set_selected(new_index)

func _unhandled_key_input(event: InputEvent) -> void:
	# Handle slot selection (1-5 keys)
	var actions = ["1", "2", "3", "4"]
	for action in actions:
		if event.is_action_pressed(action):
			# Convert to 0-based index
			inventory.set_selected(event.as_text().to_int() - 1)

	if event.is_action_pressed("throw"):
		throw_timer.start()
		print("throw!")
	
	if event.is_action_released("throw"):
		print("pressed for " + str(4096 - throw_timer.time_left))
		throw_timer.timeout.emit()

func collect_item(item: Item) -> void:
	inventory.add_item(item)

func clear_levels() -> void:
	for child in level_container.get_children():
		child.queue_free()

func load_level(scene_name: String) -> void:
	clear_levels()
	var level: Resource = ResourceLoader.load(scenes_path % scene_name)
	level_container.add_child(level.instantiate())

func _on_throw_timer_timeout() -> void:
	var item = inventory.remove_selected_item()
	if item == null:
		return
	
	var target := get_global_mouse_position() - player.global_position
	item_container.add_child(item)
	var direction := target.normalized()
	item.global_position = player.global_position + direction * 30
	
	item.linear_velocity = Vector2.ZERO
	item.apply_impulse(target.normalized() * 500)
	
	item.on_thrown()
