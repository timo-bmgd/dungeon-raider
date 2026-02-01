extends Node

@onready var timer: Timer = $level_dungeon2/CanvasLayer/Timer
@onready var label: Label = $level_dungeon2/CanvasLayer/Label
@onready var canvas_modulate: CanvasModulate = $level_dungeon2/CanvasModulate

signal dungeon_time_over
signal dungeon_second(time_remaining)

const MAX_TIME = 10.0
var time_left = MAX_TIME  # 3 minutes in seconds

func _ready():
	timer.wait_time = 1.0 
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	update_label()
	
	canvas_modulate.color = Color(0.303, 0.38, 0.554, 1.0)
	
	var game_manager = get_node("/root/Game/GameManager") 
	dungeon_time_over.connect(game_manager._on_dungeon_time_over)
	dungeon_second.connect(game_manager._on_dungeon_second)


func _on_timer_timeout():
	time_left -= 1.0
	var ratio = time_left/MAX_TIME
	canvas_modulate.color = Color(0.303, 0.38, 0.554, 1.0).darkened(1 - ratio*2 +0.2)
	
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
