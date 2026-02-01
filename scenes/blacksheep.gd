extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var current_direction := "down"
var previous_position := Vector2.ZERO

func _ready() -> void:
	previous_position = global_position

func _physics_process(_delta: float) -> void:
	update_animation()

func update_animation() -> void:
	var movement := global_position - previous_position
	
	if movement.length_squared() < 0.001:
		# Not moving -> idle, face down
		current_direction = "down"
		animated_sprite.play("idle_" + current_direction)
	else:
		# Moving -> determine direction from movement
		if abs(movement.x) > abs(movement.y):
			current_direction = "right" if movement.x > 0 else "left"
		else:
			current_direction = "down" if movement.y > 0 else "up"
		animated_sprite.play("run_" + current_direction)
	
	previous_position = global_position
