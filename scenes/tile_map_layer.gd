extends TileMapLayer

@onready var tile_map_layer: TileMapLayer = $"."

var GENERATIONS = 10

func _ready():
	randomize()
	
	var patterns = Array()
	var patterns_num = tile_map_layer.tile_set.get_patterns_count()
	
	for i in range(patterns_num):
		patterns.append(tile_map_layer.tile_set.get_pattern(i))
	
	# Spawn the first pattern(startroom)
	var pattern = patterns[0]
	tile_map_layer.set_pattern(Vector2i(0,0), pattern);
	
	for x in range(-GENERATIONS, GENERATIONS):
		for y in range(-GENERATIONS, GENERATIONS):
			if(x == 0 and y == 0):
				continue;
			# Get a random pattern
			pattern = patterns[randi() % patterns_num]
			tile_map_layer.set_pattern(Vector2i(x*pattern.get_size().x,y*pattern.get_size().y), pattern);
			# Move Generation to the right
