extends CanvasLayer

@onready var panel: Panel = $Panel

@onready var h_box_container: HBoxContainer = $Control/HBoxContainer

@onready var item_holders := h_box_container.get_children()

signal inventory_is_full

var normal_style := StyleBoxFlat.new()
var selected_style := StyleBoxFlat.new()
var currently_selected := 0

func _ready():
	init_styles()

func init_styles():
	normal_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	selected_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	
	selected_style.border_width_left = 3
	selected_style.border_width_right = 3
	selected_style.border_width_top = 3
	selected_style.border_width_bottom = 3
	selected_style.border_color = Color(0.483, 0.661, 0.835, 0.91)
	# automatically select the first item
	
	for i in item_holders:
		i.add_theme_stylebox_override("panel", normal_style)
	
	item_holders[currently_selected].add_theme_stylebox_override("panel", selected_style)

func _process(_delta):
	if Input.is_action_just_pressed("menu"):
		panel.visible = !panel.visible

func find_free_item_holder() -> Panel:
	for item_holder in item_holders:
		if item_holder.get_children().is_empty():
			return item_holder
	return null

func add_item(item: Item):
	if item.get_parent():
		var parent = item.get_parent()
		parent.call_deferred("remove_child", item)
	print("Added the item to inventory " + str(item))
	var my_item_holder := find_free_item_holder()
	if my_item_holder == null:
		inventory_is_full.emit()
	# Add as child of the button node
	my_item_holder.call_deferred("add_child",item)
	item.position = Vector2(0,0) + my_item_holder.size * 0.5
	item.in_inventory = true
		
func set_select(num:int) -> void:
	item_holders[currently_selected].add_theme_stylebox_override("panel", normal_style)
	currently_selected = num -1
	item_holders[currently_selected].add_theme_stylebox_override("panel", selected_style)	
