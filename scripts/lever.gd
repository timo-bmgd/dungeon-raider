extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2d

signal lever_activated(is_on: bool)

var activated := 0
var selected := 0

func _on_lever_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		activated = int(!bool(activated)) # genius
		set_animation_frame()
		lever_activated.emit(bool(activated))

func set_animation_frame() -> void:
	animated_sprite_2d.frame = activated + selected
	

func _on_lever_area_mouse_entered() -> void:
	selected = int(!bool(selected))*2 # genius
	set_animation_frame()


func _on_lever_area_mouse_exited() -> void:
	selected = int(!bool(selected))*2 # genius
	set_animation_frame()
