extends CanvasLayer

@onready var place_holder_1: ColorRect = $place_holder1
@onready var panel: Panel = $Panel

@onready var button: Button = $Control/HBoxContainer/Button
@onready var button_2: Button = $Control/HBoxContainer/Button2
@onready var button_3: Button = $Control/HBoxContainer/Button3
@onready var button_4: Button = $Control/HBoxContainer/Button4


func _process(delta):
	if Input.is_action_just_pressed("menu"):
		panel.visible = !panel.visible
		

func add_item(item: Item):
	if item.get_parent():
		item.get_parent().remove_child(item)
	# Add as child of the button node
	button.add_child(item)
	item.in_inventory = true
	item.position = button.position + Vector2(button.size.x / 2,1)
	print("global position item:", item.global_position)
	print("global position button:", button.global_position)
	
	item.scale = button.get_transform().get_scale() * 2.5
