extends Node

#dictionary containing a dictionary for each biome (numbered)
const BIOME_MOBS: Dictionary = {
	1:{
		"slime" : preload("res://mobs/slime.tscn")
	}
}
#variable to get random mobs
var biome_mob_arrays: Dictionary = {}


func _ready() -> void:
	#arrange biomes in array for random selection
	for biome in BIOME_MOBS:
		biome_mob_arrays[biome] = BIOME_MOBS[biome].values()


func spawn_mob(biome:int,mob=null):
	var selected_mob:PackedScene
	if mob:
		selected_mob = get_selected_mob(biome,mob)
	else:
		selected_mob = get_random_mob(biome)
	
	if selected_mob:
		var new_mob = selected_mob.instantiate()
		return new_mob
	else:
		push_warning("No mob found for biome "+str(biome) + "and mob type" +str(mob))
		return null

func get_selected_mob(biome: int, mob: String) -> PackedScene:
	if biome in BIOME_MOBS and mob in BIOME_MOBS[biome]:
		return BIOME_MOBS[biome][mob]
	return null

func get_random_mob(biome: int) -> PackedScene:
	if biome in biome_mob_arrays and not biome_mob_arrays[biome].is_empty():
		return biome_mob_arrays[biome].pick_random()
	return null

func get_biome_mobs(biome: int) -> Array:
	return biome_mob_arrays.get(biome, [])
