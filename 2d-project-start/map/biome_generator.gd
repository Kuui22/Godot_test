extends Node
#guys this biome generation is 99.9% chatgpt and 0.1% me tbh

# Size of the biome (number of tiles)
var width = 200
var height = 200
#@onready var BIOME_1_GROUND = preload("res://map/biome1_ground.tscn")
# TileMap nodes

var ground_atlas_coords = []
@onready var biome_container:Dictionary = {
	1:
		{
		 "ground_tilemap_layer":%Biome1_GroundMapLayer,
		 "object_tilemap_layer":%Biome1_ObjectMapLayer
		},
	2:
		{}
}
var ground_tilemap_layer: TileMapLayer 
var object_tilemap_layer: TileMapLayer 
var statue_pattern
var tileset_ground

var source_id = 0


# Tile indexes in the TileSet
var ground_tile_source_id = 0 
var tree_tile_source_id = 1   
var rock_tile_source_id = 2   
@onready var noise = FastNoiseLite.new()


func _ready():
	setup_noise()
	#generate_biome()

#ready up the noise generator
func setup_noise():
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

func get_tileset_size():
	if tileset_ground != null:
		var atlas_source = tileset_ground.get_source(source_id) as TileSetAtlasSource
		if atlas_source != null:
			var grid_size = atlas_source.get_atlas_grid_size()
			for x in range(grid_size.x):
				for y in range(grid_size.y):
					ground_atlas_coords.append(Vector2i(x, y))

func generate_biome(biomenumber:int=1):
	ground_tilemap_layer= biome_container[biomenumber]["ground_tilemap_layer"]
	object_tilemap_layer= biome_container[biomenumber]["object_tilemap_layer"]
	statue_pattern = biome_container[1]["object_tilemap_layer"].tile_set.get_pattern(0)
	tileset_ground = ground_tilemap_layer.tile_set
	#get all atlas coordinates of ground
	get_tileset_size()

	for x in range(-width, width + 1):
		for y in range(-height, height + 1):
			var position = Vector2i(x, y)
			set_ground_tile(position)
			rand_place_pattern(position)




func set_ground_tile(position: Vector2i):
	var height_value = noise.get_noise_2d(position.x, position.y)

	if height_value > -0.3:
		var selected_atlas_coords = ground_atlas_coords.pick_random()
		ground_tilemap_layer.set_cell(position, ground_tile_source_id, selected_atlas_coords)
	elif height_value > -0.5:
		ground_tilemap_layer.set_cell(position, rock_tile_source_id, Vector2i(0, 0))
	else:
		ground_tilemap_layer.erase_cell(position)
		
func rand_place_pattern(position: Vector2i):
	# Randomly place patterns with additional conditions
	if ground_tilemap_layer.get_cell_source_id(position) == ground_tile_source_id:
		var random_value = randf()
		if random_value < 0.0002:
			object_tilemap_layer.set_pattern(position,statue_pattern)  # Place tree
