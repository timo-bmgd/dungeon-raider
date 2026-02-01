class_name Item
extends RigidBody2D

enum ItemType {
	BOXEDLUNCH,
	CHOCOLATE,
	DIAMOND,
	HOTDOG,
	MUSHROOM,
	NOODLECUP,
	PERFECTSANDWICH,
	RATION,
	WINE
}

const ITEM_DATA: Dictionary = {
	ItemType.BOXEDLUNCH: {"name": "boxedlunch", "value": 35},
	ItemType.CHOCOLATE: {"name": "chocolate", "value": 15},
	ItemType.DIAMOND: {"name": "diamond", "value": 1000},
	ItemType.HOTDOG: {"name": "hotdog", "value": 10},
	ItemType.MUSHROOM: {"name": "mushroom", "value": 5},
	ItemType.NOODLECUP: {"name": "noodlecup", "value": 20},
	ItemType.PERFECTSANDWICH: {"name": "perfectsandwich", "value": 100},
	ItemType.RATION: {"name": "ration", "value": 25},
	ItemType.WINE: {"name": "wine", "value": 50}
}

@onready var game_manager: Node2D = get_node("/root/Game/GameManager")
@onready var enable_after_spawn: Timer = $"PickUpZone/Enable after spawn"
@onready var pick_up_zone: Area2D = $PickUpZone
@onready var rigid_collision_shape_2d: CollisionShape2D = $RigidCollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D  # Adjust this path to match your sprite node name
@onready var point_light_2d: PointLight2D = $PointLight2D

@export var item_type: ItemType = ItemType.HOTDOG:
	set(new_type):
		item_type = new_type
		_update_item_from_type()

@export var value: int = 10

@export var size = 1:
	set(new_size):
		size = new_size
		update_children_scale()

var in_inventory = false:
	set(new_value):
		in_inventory = new_value

func _update_item_from_type() -> void:
	if not ITEM_DATA.has(item_type):
		return
	
	var data = ITEM_DATA[item_type]
	value = data["value"]
	_update_sprite_texture(data["name"])

func _update_sprite_texture(item_name: String) -> void:
	if item_name.is_empty():
		return
	
	var texture_path = "res://assets/sprites/items/item_%s.png" % item_name
	
	if ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		var sprite_node = get_node_or_null("Sprite2D")  # Adjust path if needed
		if sprite_node:
			sprite_node.texture = texture
	else:
		push_warning("Item texture not found: " + texture_path)

func _ready():
	await get_tree().process_frame
	game_manager = get_node("/root/Game/GameManager")
	_update_item_from_type()

func update_children_scale():
	for child in get_children():
		child.scale = Vector2(size, size)

func _on_pick_up_zone_body_entered(body: Node2D) -> void:
	game_manager.collect_item(self)

func _on_enable_after_spawn_timeout() -> void:
	set_collision(true)

func on_thrown() -> void:
	set_collision(false)
	enable_after_spawn.wait_time = 0.945
	enable_after_spawn.one_shot = true
	enable_after_spawn.start()

func set_collision(status) -> void:
	if status:
		set_collision_mask_value(2, true)
	else:
		set_collision_mask_value(2, false)
	pick_up_zone.monitoring = status
	
func set_random_item_type() -> void:
	var total_weight: float = 0.0
	for type in ITEM_DATA:
		total_weight += 1.0 / ITEM_DATA[type]["value"]
	
	var roll: float = randf() * total_weight
	var cumulative: float = 0.0
	
	for type in ITEM_DATA:
		cumulative += 1.0 / ITEM_DATA[type]["value"]
		if roll <= cumulative:
			item_type = type
			return

func enter_inventory() -> void:
	in_inventory = true
	rotation = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	size = 2
	point_light_2d.enabled = false

func exit_inventory() -> void:
	in_inventory = false
	size = 1
	point_light_2d.enabled = true
