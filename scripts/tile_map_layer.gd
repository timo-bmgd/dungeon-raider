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
	print("\n=== Starting spawn_item() ===")
	
	# Calculate world bounds in tile coordinates
	var world_min = Vector2i(-GENERATIONS * pattern_size.x, -GENERATIONS * pattern_size.y)
	var world_max = Vector2i(GENERATIONS * pattern_size.x, GENERATIONS * pattern_size.y)
	
	print("World bounds - Min: %s, Max: %s" % [world_min, world_max])
	print("TileMapLayer transform - Position: %s, Scale: %s, Rotation: %s" % [
		tile_map_layer.global_position,
		tile_map_layer.scale,
		tile_map_layer.rotation_degrees
	])
	
	var attempts = 0
	
	while attempts < MAX_SPAWN_ATTEMPTS:
		attempts += 1
		
		# Generate random tile coordinates within world bounds
		var random_tile_pos = Vector2i(
			randi_range(world_min.x, world_max.x - 1),
			randi_range(world_min.y, world_max.y - 1)
		)
		
		print("Attempt %d: Testing position %s" % [attempts, random_tile_pos])
		
		# Check if this tile is valid for spawning
		if is_valid_spawn_location(random_tile_pos):
			print("✓ SUCCESS! Valid spawn location found at %s after %d attempts" % [random_tile_pos, attempts])
			
			# Instantiate the item
			var item = ItemScene.instantiate()
			print("  → Item instantiated from scene")
			
			# Add to scene tree
			add_child(item)
			print("  → Item added to scene tree")
			
			# seti
			item.game_manager = game_manager

			# Convert tile coordinates to local position, then to global
			var local_position = tile_map_layer.map_to_local(random_tile_pos)
			print("  → Tile local position: %s" % local_position)
			
			var global_position = tile_map_layer.to_global(local_position)
			print("  → Converted to global position: %s" % global_position)
			
			# Position the item at the correct global location
			item.global_position = global_position
			print("  → Item positioned at: %s" % item.global_position)
			
			return random_tile_pos
		else:
			print("✗ Position %s is not valid for spawning" % random_tile_pos)
	
	print("!!! FAILED to find valid spawn location after %d attempts" % MAX_SPAWN_ATTEMPTS)
	return Vector2i(-999999, -999999)


func is_valid_spawn_location(tile_coords: Vector2i) -> bool:
	"""
	Checks if a tile position is valid for item spawning.
	Uses custom data layer to determine validity.
	"""
	print("  Checking tile at %s..." % tile_coords)
	
	# Get the tile data at this position
	var tile_data = tile_map_layer.get_cell_tile_data(tile_coords)
	
	if tile_data == null:
		print("  → No tile exists at this position")
		return false
	
	# Check if the custom data layer exists
	if not tile_data.get_custom_data(VALID_SPAWN_CUSTOM_DATA_LAYER):
		print("  → Warning: Custom data layer '%s' not found on this tile" % VALID_SPAWN_CUSTOM_DATA_LAYER)
		return false
	
	# Get the custom data value
	var spawn_data = tile_data.get_custom_data(VALID_SPAWN_CUSTOM_DATA_LAYER)
	print("  → Custom data '%s' = %s" % [VALID_SPAWN_CUSTOM_DATA_LAYER, spawn_data])
	
	# Check if it matches the valid spawn value
	var is_valid = (spawn_data == VALID_SPAWN_VALUE)
	print("  → Is valid spawn location: %s" % is_valid)
	
	return is_valid


# Optional: Test function to spawn multiple items
func test_spawn_items(count: int = 1000):
	print("\n=== Testing spawn of %d items ===" % count)
	for i in range(count):
		print("\n--- Spawning item %d/%d ---" % [i + 1, count])
		var spawn_pos = spawn_item()
		if spawn_pos != Vector2i(-999999, -999999):
			print("Item %d spawned successfully at %s" % [i + 1, spawn_pos])
		else:
			print("Item %d failed to spawn" % [i + 1])
