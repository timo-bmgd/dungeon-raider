extends Control

var progress = []
var sceneName
var scene_load_status = 0

@onready var loading_status: Label = $"../LoadingStatus"

var loading_scene = false
	
func _process(delta):
	if loading_scene:
		scene_load_status = ResourceLoader.load_threaded_get_status(sceneName, progress)
		loading_status.text = str(floor(progress[0]*100)) + "%"
		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
			var newScene = ResourceLoader.load_threaded_get(sceneName)
			get_tree().change_scene_to_packed(newScene)
			loading_scene = false

func load_scene(scene_name: String):
	loading_scene = true
	sceneName = "res://scenes/%s.tscn" % scene_name
	print(sceneName)
	ResourceLoader.load_threaded_request(sceneName)

func _on_start_game_pressed() -> void:
	load_scene("game")

func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_to_menu_pressed() -> void:
	load_scene("main_menu")
