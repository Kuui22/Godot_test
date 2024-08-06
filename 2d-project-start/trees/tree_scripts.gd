extends Node
class_name treefunctions

#generating trees while moving
func gencheck_trees(player,tree_radius,tree_count,tree_scenes,parent):
	var center = player.global_position
	var trees_in_radius = get_trees_in_radius(center, tree_radius, parent)
	if(trees_in_radius.size() == 0):
		generate_random_trees(center, tree_radius, tree_count,tree_scenes,parent)

#get trees near player
func get_trees_in_radius(center: Vector2, radius: float, parent):
	for child in parent.get_children():
		if child is Node2D and "tree" in child.name:
			var distance = child.global_position.distance_to(center)
			if distance <= radius:
				return[child]
	return []

func generate_random_trees(center: Vector2, radius: float, count: int,tree_scenes,parent):
	for i in range(count):
		#select random tree scene from dict
		var tree_name = tree_scenes.keys().pick_random()
		var tree_scene = tree_scenes[tree_name]
		#assert check and place tree in random pos in radius
		if tree_scene is PackedScene:
			var random_position = center + Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			var tree_instance = tree_scene.instantiate()
			tree_instance.name = "tree_%d" % i
			tree_instance.global_position = random_position
			parent.add_child(tree_instance)
			#print("Generated tree at:", random_position)
