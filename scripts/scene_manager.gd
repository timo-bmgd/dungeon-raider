extends Node

var current_scene = null
var scenes_path = "res://scenes/%s.tscn"

enum State {MAIN_MENU, GAME}
var state = State.MAIN_MENU

var game_state = {
	"money": 0
}

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(-1)

func save_game_state(money_amount: int):
	game_state["money"] = money_amount
	print("Game state saved: %d items in inventory, %d items in spaceship, $%d" % [
		money_amount
	])

func get_game_state() -> Dictionary:
	return game_state

func reset_game_state():
	game_state = {
		"inventory_items": [],
		"spaceship_items": [],
		"money": 0
	}
	
func goto_scene(scene_name):
	match scene_name:
		"game":
			state = State.GAME
		"main_menu":
			state = State.MAIN_MENU
		_:
			state = State.MAIN_MENU
	_deferred_goto_scene.call_deferred(scene_name)

func _deferred_goto_scene(scene_name):
	current_scene.free()
	
	var path = scenes_path % scene_name
	var s = ResourceLoader.load(path)
	
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
	print("updating STATE to %s" % scene_name)
