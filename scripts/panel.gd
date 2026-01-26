extends Panel

@onready var stylebox: StyleBoxTexture = get_theme_stylebox("panel")
@onready var texture: NoiseTexture2D = stylebox.texture
@onready var noise: FastNoiseLite = texture.noise

var old

func _ready() -> void:
	old = maxf(randf(), 0.2)


func _process(delta):
	var updated = old + maxf(randf(), 0.2) * delta/10
	noise.domain_warp_frequency = updated
