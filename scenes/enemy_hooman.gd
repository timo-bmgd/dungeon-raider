extends CharacterBody2D

@export var speed = 150.0
@export var change_direction_time = 2.0  # How often to pick new direction

@onready var ray_right: RayCast2D = $right
@onready var ray_left: RayCast2D = $left
@onready var ray_up: RayCast2D = $up
@onready var ray_down: RayCast2D = $down

var current_direction = Vector2.ZERO
var direction_timer = 0.0

func _ready():
	pick_random_direction()

func _physics_process(delta):
	direction_timer -= delta
	
	# Pick new random direction periodically
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
	
	# If blocked, pick new direction immediately
	if adjusted_direction == Vector2.ZERO:
		pick_random_direction()
		adjusted_direction = current_direction
	
	velocity = adjusted_direction.normalized() * speed
	move_and_slide()

func pick_random_direction():
	# Pick random cardinal or diagonal direction
	current_direction = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	)
	direction_timer = change_direction_time
