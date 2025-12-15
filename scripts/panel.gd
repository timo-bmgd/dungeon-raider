extends Panel

@onready var stylebox: StyleBoxTexture = get_theme_stylebox("panel")
@onready var texture: NoiseTexture2D = stylebox.texture
@onready var noise: FastNoiseLite = texture.noise


func _process(_delta):
	noise.seed = randi() 
	noise.frequency = maxf(randf(), 0.2)
	noise.domain_warp_frequency = randf()*1000
