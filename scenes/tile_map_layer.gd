extends TileMapLayer

@onready var tile_map_layer: TileMapLayer = $"."

func _ready():
	var pattern = tile_map_layer.tile_set.get_pattern(1);
	tile_map_layer.set_pattern(Vector2i(0,0), pattern);
