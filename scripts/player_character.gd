extends CharacterBody2D
@export var run_speed = 400
@export var sneak_speed = 200

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
