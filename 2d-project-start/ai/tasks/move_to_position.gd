extends BTAction

@export var target_position_var := &"pos"


@export var speed:float = 300.0
@export var tolerance:float = 10.0

func _tick(_delta) -> Status:
	var target_pos:Vector2 = blackboard.get_var(target_position_var, Vector2.ZERO)
	var distance:float = agent.global_position.distance_to(target_pos)
	
	if distance < tolerance:
		agent.move(target_pos,0)
		return SUCCESS
	
	else:
		agent.move(target_pos,speed)
		return RUNNING
		
