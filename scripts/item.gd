class_name Item
extends RigidBody2D

@onready var game_manager: Node2D = get_node("/root/Game/GameManager")
@onready var enable_after_spawn: Timer = $"PickUpZone/Enable after spawn"
@onready var pick_up_zone: Area2D = $PickUpZone
@onready var rigid_collision_shape_2d: CollisionShape2D = $RigidCollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D  # Adjust this path to match your sprite node name

@export var value = 10

@export var item_name: String = "":
	set(new_name):
		item_name = new_name
		_update_sprite_texture()

@export var size = 1:
	set(value):
		size = value
		update_children_scale()

var in_inventory = false:
	set(value):
		in_inventory = value

func _update_sprite_texture() -> void:
	if item_name.is_empty():
		return
	
	var texture_path = "res://assets/sprites/food/bulk-background-remover/item_%s.png" % item_name
	
	# Check if texture exists before loading
	if ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		# In editor, we need to get the node directly since @onready hasn't run
		var sprite_node = get_node_or_null("Sprite2D")  # Adjust path if needed
		if sprite_node:
			sprite_node.texture = texture
	else:
		push_warning("Item texture not found: " + texture_path)

func _ready():
	await get_tree().process_frame
	game_manager = get_node("/root/Game/GameManager")
	# Ensure texture is set on ready as well
	_update_sprite_texture()

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

func enter_inventory() -> void:
	in_inventory = true
	rotation = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	size = 2

func exit_inventory() -> void:
	in_inventory = false
	size = 1
