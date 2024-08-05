extends TileMap

const green_block_atlas_pos = Vector2i(2,0) #level 0 floor
const white_block_atlas_pos = Vector2i(3,0) #level 1 walls
const boundary_block_atlas_pos = Vector2i(0,1) #invisible walls
const main_source = 0

enum layers{
	level0 = 0,
	level1 = 1,
	level2 = 2,
	}

func _ready():
	place_platform()
	place_boundaries()

func place_platform():
	for y in range(9):
		for x in range(9):
			set_cell(layers.level0, Vector2i(-1 + x, -1 + y), main_source, green_block_atlas_pos)
			
	set_cell(layers.level1, Vector2i(2, 2), main_source, white_block_atlas_pos)

func place_boundaries():
	var offsets = [
		Vector2i(0,-1),
		Vector2i(0,1),
		Vector2i(1,0),
		Vector2i(-1,0),
	]
	#get all cells used on floor
	var used = get_used_cells(layers.level0)
	for spot in used:
		for offset in offsets:
			var current_spot = spot + offset
			if get_cell_source_id(layers.level0, current_spot) == -1: #if empty
				set_cell(layers.level0, current_spot, main_source, boundary_block_atlas_pos)
				
