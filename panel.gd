extends Panel

@onready var stylebox: StyleBoxTexture = get_theme_stylebox("panel").duplicate()
@onready var texture: NoiseTexture2D = stylebox.texture.duplicate()
@onready var noise: FastNoiseLite = texture.noise.duplicate()


func _physics_process(delta):
	noise.seed = randi() 
	noise.frequency = maxf(randf(), 0.2)
	noise.domain_warp_frequency = randf()*1000
