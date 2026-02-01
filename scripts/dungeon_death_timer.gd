extends Node

@onready var timer: Timer = $level_dungeon2/CanvasLayer/Timer
@onready var label: Label = $level_dungeon2/CanvasLayer/Label

signal dungeon_time_over
signal dungeon_second(time_remaining)

var time_left = 5.0  # 3 minutes in seconds

func _ready():
	timer.wait_time = 1.0  # Update every second
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	update_label()
	
	# Find GameManager (assuming it's an autoload or has a specific name)
	var game_manager = get_node("/root/Game/GameManager")  # Adjust path
	dungeon_time_over.connect(game_manager._on_dungeon_time_over)
	dungeon_second.connect(game_manager._on_dungeon_second)


func _on_timer_timeout():
	time_left -= 1.0
	
	if time_left <= 0:
		time_left = 0
		timer.stop()
		dungeon_time_over.emit()
	else:
		dungeon_second.emit(time_left)
	
	update_label()

func update_label():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	if time_left < 30:
		label.add_theme_color_override("font_color", Color(0.813, 0.068, 0.241, 1.0))
	label.text = "%d:%02d" % [minutes, seconds]
