extends CanvasLayer

@onready var place_holder_1: ColorRect = $place_holder1
@onready var panel: Panel = $Panel


func _process(delta):
	if Input.is_action_just_pressed("menu"):
		panel.visible = !panel.visible
		

func add_item(item):
	if item.get_parent():
		item.get_parent().remove_child(item)
	# Add as child of this node
	add_child(item)
	item.in_inventory = true
	
	item.position = place_holder_1.position + (0.5*place_holder_1.size)
