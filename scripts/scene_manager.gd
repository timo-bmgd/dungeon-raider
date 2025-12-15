extends Node

var current_scene = null
var scenes_path = "res://scenes/%s.tscn"

enum State {MAIN_MENU, GAME}
var state = State.MAIN_MENU

func _ready():
	var root = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)
	
func goto_scene(scene_name):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	match scene_name:
		"game":
			state = State.GAME
		"main_menu":
			state = State.MAIN_MENU
		_:
			state = State.MAIN_MENU

	_deferred_goto_scene.call_deferred(scene_name)


func _deferred_goto_scene(scene_name):
	# It is now safe to remove the current scene.
	current_scene.free()
	
	# Construct path
	var path = scenes_path % scene_name
	
	# Load the new scene.
	var s = ResourceLoader.load(path)
	
	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
	
	print("updating STATE to %s" % scene_name)
	
		
