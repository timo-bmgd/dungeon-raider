extends CanvasLayer

@onready var place_holder_1: ColorRect = $place_holder1


func add_item(item):
	if item.get_parent():
		item.get_parent().remove_child(item)
	# Add as child of this node
	add_child(item)
	item.in_inventory = true
	
	item.position = place_holder_1.position + (0.5*place_holder_1.size)
