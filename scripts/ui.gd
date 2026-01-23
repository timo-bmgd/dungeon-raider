# ui.gd - Purely visual, listens to inventory signals

extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var h_box_container: HBoxContainer = $Control/HBoxContainer
@onready var item_holders: Array[Node]

var normal_style := StyleBoxFlat.new()
var selected_style := StyleBoxFlat.new()

var inventory: Node  # Reference set by game_manager or via export

func _ready() -> void:
	item_holders = h_box_container.get_children()
	init_styles()
	# Set initial selection
	_on_selection_changed(inventory.get_selected_slot())


func init_styles() -> void:
	normal_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	selected_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	
	selected_style.border_width_left = 3
	selected_style.border_width_right = 3
	selected_style.border_width_top = 3
	selected_style.border_width_bottom = 3
	selected_style.border_color = Color(0.483, 0.661, 0.835, 0.91)
	
	for holder in item_holders:
		holder.add_theme_stylebox_override("panel", normal_style)

func connect_to_inventory(inv: Node) -> void:
	inventory = inv
	inventory.item_added.connect(_on_item_added)
	inventory.item_removed.connect(_on_item_removed)
	inventory.selection_changed.connect(_on_selection_changed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		panel.visible = !panel.visible

func _on_item_added(item: Item, slot: int) -> void:
	if slot < 0 or slot >= item_holders.size():
		return
	
	var holder: Panel = item_holders[slot]
	
	# Remove from previous parent if needed
	if item.get_parent():
		item.get_parent().call_deferred("remove_child", item)
	
	holder.call_deferred("add_child", item)
	item.position = Vector2.ZERO + holder.size * 0.5
	print("Added item to inventory slot %d: %s" % [slot, str(item)])

func _on_item_removed(item: Item, slot: int) -> void:
	if item.get_parent():
		item.get_parent().remove_child(item)
	print("Removed item from inventory slot %d: %s" % [slot, str(item)])

func _on_selection_changed(slot: int) -> void:
	# Reset all to normal style
	for holder in item_holders:
		holder.add_theme_stylebox_override("panel", normal_style)
	# Highlight selected
	if slot >= 0 and slot < item_holders.size():
		item_holders[slot].add_theme_stylebox_override("panel", selected_style)
		print("added style")
