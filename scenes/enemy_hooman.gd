extends CharacterBody2D

@export var speed = 150.0
@export var change_direction_time = 2.0
@export var rotation_smoothness = 5.0

@onready var ray_up = $up
@onready var ray_down = $down
@onready var ray_left = $left
@onready var ray_right = $right
@onready var animated_sprite = $AnimatedSprite2D
@onready var light = $PointLight2D

var current_direction = Vector2.ZERO
var direction_timer = 0.0

func _ready():
	pick_random_direction()

func _physics_process(delta):
	direction_timer -= delta
	
	if direction_timer <= 0:
		pick_random_direction()
	
	# Check for walls and adjust direction
	var adjusted_direction = current_direction
	
	if ray_up.is_colliding() and current_direction.y < 0:
		adjusted_direction.y = 0
	if ray_down.is_colliding() and current_direction.y > 0:
		adjusted_direction.y = 0
	if ray_left.is_colliding() and current_direction.x < 0:
		adjusted_direction.x = 0
	if ray_right.is_colliding() and current_direction.x > 0:
		adjusted_direction.x = 0
	
	if adjusted_direction == Vector2.ZERO:
		pick_random_direction()
		adjusted_direction = current_direction
	
	velocity = adjusted_direction.normalized() * speed
	move_and_slide()
	
	# Update animation and light rotation
	update_animation(adjusted_direction)
	update_light_rotation(adjusted_direction, delta)

func update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		animated_sprite.stop()
		return
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animated_sprite.play("run_right")
		else:
			animated_sprite.play("run_left")
	else:
		if direction.y > 0:
			animated_sprite.play("run_down")
		else:
			animated_sprite.play("run_up")

func update_light_rotation(direction: Vector2, delta):
	if direction != Vector2.ZERO:
		var target_angle = direction.angle()
		light.rotation = lerp_angle(light.rotation, target_angle, rotation_smoothness * delta)

func pick_random_direction():
	current_direction = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	)
	direction_timer = change_direction_time
