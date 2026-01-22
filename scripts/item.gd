class_name Item
extends RigidBody2D
@onready var game_manager: Node2D = %GameManager
@onready var enable_after_spawn: Timer = $"PickUpZone/Enable after spawn"
@onready var pick_up_zone: Area2D = $PickUpZone
@onready var rigid_collision_shape_2d: CollisionShape2D = $RigidCollisionShape2D

var in_inventory = false:
	set(value):
		in_inventory = value
		print("in inventory changed to:" + str(value))

func _on_pick_up_zone_body_entered(body: Node2D) -> void:
	print("item collected by:" + str(body.name))
	game_manager.collect_item(self)
	

func _on_enable_after_spawn_timeout() -> void:
	print("enabled the item after spawn timeout")
	set_collision(true)

func on_thrown() -> void:
	set_collision(false)
	enable_after_spawn.wait_time = 0.945
	enable_after_spawn.one_shot = true
	enable_after_spawn.start()

func set_collision(status) -> void:
	print("setting item collision to " + str(status))
	if status:
		set_collision_mask_value(2, true)  # Enable collision with player (layer 2)
	else:
		set_collision_mask_value(2, false)  # Disable collision with player (layer 2)
	pick_up_zone.monitoring = status
