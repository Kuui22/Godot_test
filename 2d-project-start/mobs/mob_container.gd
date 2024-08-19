extends Node


const biome_1_mobs:Dictionary = {
	"slime" : preload("res://mobs/slime.tscn")
}

var biome1array:Array = []

func _ready() -> void:
	for key in biome_1_mobs:
		biome1array.append(biome_1_mobs[key])


func spawn_mob(biome:int,mob=null):
	var selected_mob
	if mob:
		selected_mob = get_selected_mob(biome,mob)
	else:
		selected_mob = get_random_mob(biome)
			
	var new_mob = selected_mob.instantiate()
	return new_mob

func get_selected_mob(biome:int,mob:String):
	var selected_mob
	match biome:
		1:
			selected_mob = biome_1_mobs[mob]
	return selected_mob

func get_random_mob(biome:int):
	var selected_mob
	var selector
	match biome:
		1:
			selector = randi_range(0,biome1array.size()-1)
			selected_mob = biome1array[selector]
	return selected_mob
	
