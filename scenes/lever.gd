extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2d

var activated := 0
var selected := 0

func _on_lever_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Alternative: if you really want to use your "click" action
	if event.is_action_pressed("click"):
		activated = int(!bool(activated)) # genius
		print("Lever clicked:" + str(activated))
		set_animation_frame()

func set_animation_frame() -> void:
	print("activated:"+str(activated))
	print("selected:"+str(selected))
	animated_sprite_2d.frame = activated + selected
	

func _on_lever_area_mouse_entered() -> void:
	selected = int(!bool(selected))*2 # genius
	set_animation_frame()


func _on_lever_area_mouse_exited() -> void:
	selected = int(!bool(selected))*2 # genius
	set_animation_frame()
