extends CharacterBody2D
@export var run_speed = 200
@export var sneak_speed = 100
@export var push_force: float = 30.0

@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var current_direction := "down"


func _process(_delta):
	var direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	var sneak = Input.get_action_strength("sneak")
	
	direction = direction.normalized()
	
	if(sneak == 0):
		velocity = direction * run_speed
	else:
		velocity = direction * sneak_speed
		
	update_animation(direction)
	move_and_slide()
	push_items()

func update_animation(direction: Vector2) -> void:
	# Update facing direction if moving
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			# Horizontal movement is stronger
			current_direction = "right" if direction.x > 0 else "left"
		else:
			# Vertical movement is stronger
			current_direction = "down" if direction.y > 0 else "up"
	
	# Play run or idle animation
	if velocity == Vector2.ZERO:
		animated_sprite.play("idle_" + current_direction)
	else:
		animated_sprite.play("run_" + current_direction)
		
func push_items() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		# Check if it's a RigidBody2D on layer 3 (items)
		if collider is RigidBody2D and collider.get_collision_layer_value(3):
			var push_dir := -collision.get_normal()
			collider.apply_central_impulse(push_dir * push_force)


func _on_game_manager_level_changed(level_name: Variant) -> void:
	if point_light_2d == null:
		return
	# IF THE PLAYER IS IN THE DUNGEON:
	if level_name == %GameManager.Level.keys()[1]:
		# turn on light
		point_light_2d.visible = true
		print("enabled light")
	else:
		# turn off light
		point_light_2d.visible = false
