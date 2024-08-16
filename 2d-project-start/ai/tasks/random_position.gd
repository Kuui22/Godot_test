extends BTAction


@export var min_range:float = 400.0
@export var max_range:float = 1000.0

@export var target_position:StringName = &"pos"
#@export var target_direction:StringName = &"dir"


func _tick(_delta:float) -> Status:
	var pos:Vector2
	pos = update_target_position()
	blackboard.set_var(target_position,pos)
	print(pos)
	
	return SUCCESS

func update_target_position():
	var movement_vector:Vector2 = Vector2(randf_range(-min_range, max_range), randf_range(-min_range, max_range))
	var final_position:Vector2 = agent.global_position + movement_vector
	return final_position
'''
func is_at_target_position(): 
	#stop moving when at target +/- tolerance
	return (target_position - global_position).length() < TOLERANCE
	
'''
