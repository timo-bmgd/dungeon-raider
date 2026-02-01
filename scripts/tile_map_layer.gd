extends TileMapLayer
@onready var tile_map_layer: TileMapLayer = $"."

# Preload the item scene at the top of your script
const ItemScene = preload("res://scenes/item.tscn")
@onready var game_manager: Node2D = %GameManager



@export var GENERATIONS = 5
@export var ITEM_COUNT = 20
var pattern_size: Vector2i  # Will store the pattern size for world bounds calculation

# Configuration for item spawning
const MAX_SPAWN_ATTEMPTS = 1000  # Prevent infinite loops
const VALID_SPAWN_CUSTOM_DATA_LAYER = "spawnable"  # Name of custom data layer
const VALID_SPAWN_VALUE = true  # Value that indicates a valid spawn location

func _ready():
	randomize()
	
	var patterns = Array()
	var patterns_num = tile_map_layer.tile_set.get_patterns_count()
	print("Generator found %s patterns" % patterns_num)
	
	for i in range(patterns_num):
		patterns.append(tile_map_layer.tile_set.get_pattern(i))
	
	# Spawn the first pattern(startroom)
	var pattern = patterns[0]
	pattern_size = pattern.get_size()  # Store pattern size for later use
	print("Pattern size detected: %s" % pattern_size)
	
	tile_map_layer.set_pattern(Vector2i(0,0), pattern)
	
	for x in range(-GENERATIONS, GENERATIONS):
		for y in range(-GENERATIONS, GENERATIONS):
			if(x == 0 and y == 0):
				continue
			# Get a random pattern
			var pattern_indice = randi() % patterns_num
			while pattern_indice == 0: #avoid spawing the start pattern again
				pattern_indice = randi() % patterns_num
			pattern = patterns[pattern_indice]
			tile_map_layer.set_pattern(Vector2i(x*pattern.get_size().x, y*pattern.get_size().y), pattern)
	
	print("World generation complete. World bounds: (%s, %s) to (%s, %s)" % [
		-GENERATIONS * pattern_size.x,
		-GENERATIONS * pattern_size.y,
		GENERATIONS * pattern_size.x,
		GENERATIONS * pattern_size.y
	])
	
	# Example: Test spawn_item after world generation
	test_spawn_items(ITEM_COUNT)


func spawn_item() -> Vector2i:
	
	# Calculate world bounds in tile coordinates
	var world_min = Vector2i(-GENERATIONS * pattern_size.x, -GENERATIONS * pattern_size.y)
	var world_max = Vector2i(GENERATIONS * pattern_size.x, GENERATIONS * pattern_size.y)
	
	
	var attempts = 0
	
	while attempts < MAX_SPAWN_ATTEMPTS:
		attempts += 1
		
		# Generate random tile coordinates within world bounds
		var random_tile_pos = Vector2i(
			randi_range(world_min.x, world_max.x - 1),
			randi_range(world_min.y, world_max.y - 1)
		)
				
		# Check if this tile is valid for spawning
		if is_valid_spawn_location(random_tile_pos):			
			# Instantiate the item
			var item = ItemScene.instantiate()			
			# Add to scene tree
			add_child(item)			
			# seti
			item.game_manager = game_manager

			# Convert tile coordinates to local position, then to global
			var local_position = tile_map_layer.map_to_local(random_tile_pos)			
			var global_position = tile_map_layer.to_global(local_position)			
			# Position the item at the correct global location
			item.global_position = global_position
			
			return random_tile_pos

	return Vector2i(-999999, -999999)


func is_valid_spawn_location(tile_coords: Vector2i) -> bool:
	"""
	Checks if a tile position is valid for item spawning.
	Uses custom data layer to determine validity.
	"""	
	# Get the tile data at this position
	var tile_data = tile_map_layer.get_cell_tile_data(tile_coords)
	
	if tile_data == null:
		return false
	
	# Check if the custom data layer exists
	if not tile_data.get_custom_data(VALID_SPAWN_CUSTOM_DATA_LAYER):
		return false
	
	# Get the custom data value
	var spawn_data = tile_data.get_custom_data(VALID_SPAWN_CUSTOM_DATA_LAYER)
	
	# Check if it matches the valid spawn value
	var is_valid = (spawn_data == VALID_SPAWN_VALUE)
	
	return is_valid


# Optional: Test function to spawn multiple items
func test_spawn_items(count: int = 1000):
	for i in range(count):
		var spawn_pos = spawn_item()
