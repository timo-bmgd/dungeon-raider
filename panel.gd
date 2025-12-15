extends Panel

var noise

func _ready() -> void:
	noise = self.get_theme_stylebox("panel").texture.noise

func _physics_process(delta):
	noise.seed = randi() 
	noise.frequency = maxf(randf(), 0.2)
	noise.domain_warp_frequency = randf()*1000
