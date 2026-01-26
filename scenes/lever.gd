extends AnimatedSprite2D
			
			
func _ready() -> void:
	print("sready")
	
	
func _on_lever_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Alternative: if you really want to use your "click" action
	if event.is_action_pressed("click"):
		print("Sprite clicked via action!")


func _on_lever_area_mouse_entered() -> void:
	print("mouse entered")
	pass # Replace with function body.


func _on_lever_area_mouse_exited() -> void:
	print("mouse left")
	pass # Replace with function body.
