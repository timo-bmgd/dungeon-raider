extends CharacterBody2D
@export var run_speed = 400
@export var sneak_speed = 200

func _process(delta):
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
		
	move_and_slide()
