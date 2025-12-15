extends Control

enum Status {MAIN, INGAME}

var status = Status.MAIN

var progress = []
var sceneName
var scene_load_status = 0
var scenes_path = "res://scenes/%s.tscn"


@onready var loading_status: Label = $"../LoadingStatus"

	
func _on_start_game_pressed() -> void:
	status = Status.INGAME
	var scene_name = scenes_path % "game"
	SceneManager.goto_scene(scene_name)
	# load_scene("game")

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_to_menu_pressed() -> void:
	status = Status.MAIN
	var scene_name = scenes_path % "main_menu"
	SceneManager.goto_scene(scene_name)
