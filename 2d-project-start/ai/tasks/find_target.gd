extends BTAction

@export var group:StringName
@export var target_var:StringName = &"target"

#var target = get_player_node(group)



func _tick(_delta):
	'''
	if group == "mobs":
		target = get_enemy_node()
	elif group == "player":
		target = get_player_node()
	'''
	
	#blackboard.set_var(target_var, target)
	return SUCCESS
		
		
func get_player_node():
	var nodes:Array[Node] = agent.get_tree().get_nodes_in_group(group)
	return nodes[0]

func get_enemy_node():
	pass
