extends BTAction


@export var min_range:float
@export var max_range:float

@export var target_position:StringName = &"pos"
@export var target_direction:StringName = &"dir"


func tick(_delta:float) -> Status:
	var pos:Vector2
	
	
	return SUCCESS

'''
func update_target_position():
	var target_vector = Vector2(randf_range(-32, 32), randf_range(-32, 32))
	target_position = start_position + target_vector

func is_at_target_position(): 
	#stop moving when at target +/- tolerance
	return (target_position - global_position).length() < TOLERANCE
	
'''
