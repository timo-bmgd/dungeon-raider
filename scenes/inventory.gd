# inventory.gd - The single source of truth for inventory state

extends Node

const MAX_SLOTS := 5

signal item_added(item: Item, slot: int)
signal item_removed(item: Item, slot: int)
signal selection_changed(slot: int)
signal inventory_full

var slots: Dictionary[int, Item] = {}
var selected_slot: int = 0:
	set(value):
		selected_slot = clampi(value, 0, MAX_SLOTS - 1)
		selection_changed.emit(selected_slot)

func _ready() -> void:
	# Initialize empty slots
	for i in range(MAX_SLOTS):
		slots[i] = null

func is_full() -> bool:
	return find_empty_slot() == -1

func is_slot_empty(slot: int) -> bool:
	return slot >= 0 and slot < MAX_SLOTS and slots[slot] == null

func find_empty_slot() -> int:
	for i in range(MAX_SLOTS):
		if slots[i] == null:
			return i
	return -1

func add_item(item: Item) -> bool:
	var slot := find_empty_slot()
	if slot == -1:
		inventory_full.emit()
		return false
	
	slots[slot] = item
	item.in_inventory = true
	item_added.emit(item, slot)
	return true

func add_item_to_slot(item: Item, slot: int) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		return false
	if slots[slot] != null:
		return false
	
	slots[slot] = item
	item.in_inventory = true
	item_added.emit(item, slot)
	return true

func remove_item(slot: int) -> Item:
	if slot < 0 or slot >= MAX_SLOTS:
		return null
	
	var item: Item = slots[slot]
	if item == null:
		return null
	
	slots[slot] = null
	item.in_inventory = false
	item_removed.emit(item, slot)
	return item

func remove_selected_item() -> Item:
	return remove_item(selected_slot)

func get_item(slot: int) -> Item:
	if slot < 0 or slot >= MAX_SLOTS:
		return null
	return slots[slot]

func get_selected_item() -> Item:
	return slots[selected_slot]

func set_selected(slot: int) -> void:
	selected_slot = slot

func get_selected_slot() -> int:
	return selected_slot
