extends Node

#guys this biome generation is 99.9% chatgpt and 0.1% me tbh


# Size of the biome (number of tiles)
var width = 200
var height = 200

# TileMap nodes
@onready var ground_tilemap_layer: TileMapLayer = %GroundMapLayer
@onready var object_tilemap_layer: TileMapLayer = $ObjectMapLayer
var ground_atlas_coords = []




@onready var tileset_ground := ground_tilemap_layer.tile_set
var source_id = 0



# Tile indexes in the TileSet
var ground_tile_source_id = 0 
var tree_tile_source_id = 1   
var rock_tile_source_id = 2   
var noise = FastNoiseLite.new()
func _ready():
	# Set the random seed for variability
	noise.seed = randi()

	# Set the noise type (choose based on your needs)
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

	# Configure the frequency of the noise
	noise.frequency = 0.01  # Lower values create smoother noise, higher values create more granular noise

	# Configure fractal settings if you want to add complexity
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM  # Fractal Brownian Motion for terrain-like noise
	noise.fractal_octaves = 5  # Number of octaves to sum
	noise.fractal_gain = 0.5  # How much each octave contributes to the overall shape
	noise.fractal_lacunarity = 2.0  # Frequency multiplier between octaves

	# Optional: Adjust domain warp settings for more complex warping effects
	noise.domain_warp_enabled = false  # Set to true if you want to warp the noise
	generate_biome()


func generate_biome():
	#get all atlas coordinates of ground
	if tileset_ground != null:
		var atlas_source = tileset_ground.get_source(source_id) as TileSetAtlasSource
		if atlas_source != null:
			var grid_size = atlas_source.get_atlas_grid_size()
			for x in range(grid_size.x):
				for y in range(grid_size.y):
					ground_atlas_coords.append(Vector2i(x, y))
	for x in range(width):
		for y in range(height):
			# Generate heightmap using noise
			var height_value = noise.get_noise_2d(x, y)
			var position = Vector2i(x, y)
			
			# Decide tile based on height value
			if height_value > -0.3:
				#var atlas_index = randi() % ground_atlas_coords.size()  # Randomly select an atlas coordinate
				#var selected_atlas_coords = ground_atlas_coords[atlas_index]
				var selected_atlas_coords = ground_atlas_coords.pick_random()
				ground_tilemap_layer.set_cell(position, ground_tile_source_id, selected_atlas_coords)  # Grass with random atlas coords
			elif height_value > -0.5:
				ground_tilemap_layer.set_cell(position, rock_tile_source_id, Vector2i(0, 0))  # Rock
			else:
				ground_tilemap_layer.erase_cell(position)  # Remove tile (e.g., water or empty)

			# Randomly place objects with additional conditions
			if ground_tilemap_layer.get_cell_source_id(position) == ground_tile_source_id:
				var random_value = randf()
				if random_value < 0.1:
					object_tilemap_layer.set_cell(position, tree_tile_source_id, Vector2i(0, 0))  # Place tree
				elif random_value < 0.05:
					object_tilemap_layer.set_cell(position, rock_tile_source_id, Vector2i(0, 0))  # Place rock
