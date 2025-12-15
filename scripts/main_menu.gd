extends Control


@onready var loading_status: Label = $"../LoadingStatus"

@onready var start_game: Button = $StartGame
@onready var back_to_menu: Button = $BackToMenu
@onready var options: Button = $Options
@onready var exit: Button = $Exit

func _ready():
	print("asking for update to STATE")
	match SceneManager.state:
		SceneManager.State.GAME:
			start_game.visible = false;
			back_to_menu.visible = true;
		SceneManager.State.MAIN_MENU:
			start_game.visible = true;
			back_to_menu.visible = false;

	
func _on_start_game_pressed() -> void:
	SceneManager.goto_scene("game")
	# load_scene("game")

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_to_menu_pressed() -> void:
	SceneManager.goto_scene("main_menu")
