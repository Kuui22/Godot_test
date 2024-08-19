extends Node


var placed_positions = []
@export var min_distance: float = 20.0  # distance between trees

#generate trees while moving
func check_and_generate_trees(player: Node2D, tree_radius: float, tree_count: int, tree_scenes: Dictionary, parent: Node) -> void:
	var center = player.global_position
	var trees_in_radius = get_trees_in_radius(center, tree_radius, parent)
	if trees_in_radius.is_empty(): #if no trees near player
		generate_random_trees(center, tree_radius, tree_count, tree_scenes, parent)

# Get trees near player
func get_trees_in_radius(center: Vector2, radius: float, parent: Node) -> Array:
	var trees_in_radius = []
	for child in parent.get_children():
		if child is Node2D and child.is_in_group("trees"):
			if child.global_position.distance_squared_to(center) <= radius * radius: #claude said that squared is faster than distance_to
				trees_in_radius.append(child)
	return trees_in_radius

func generate_random_trees(center: Vector2, radius: float, count: int, tree_scenes: Dictionary, parent: Node) -> void:
	var attempts = 0
	var max_attempts = count * 3  #change attempts limit here

	for i in range(count):
		var tree_name = tree_scenes.keys().pick_random()
		var tree_scene = tree_scenes[tree_name]

		if not tree_scene is PackedScene:
			push_warning("Invalid tree scene for"+str(tree_name))
			continue

		var valid_position = false
		var random_position = Vector2.ZERO

		while not valid_position and attempts < max_attempts:
			random_position = center + Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			valid_position = true

			for pos in placed_positions:
				if pos.distance_squared_to(random_position) < min_distance * min_distance:
					valid_position = false
					break

			attempts += 1

		if valid_position:
			var tree_instance = tree_scene.instantiate()
			tree_instance.name = "tree_%d" % placed_positions.size()
			placed_positions.append(random_position)
			tree_instance.global_position = random_position
			parent.add_child(tree_instance)
		else:
			print("Failed to find position for tree %d after %d attempts" % [i, max_attempts])

func clear_placed_positions() -> void:
	placed_positions.clear()
