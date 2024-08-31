extends Area2D

@onready var static_position:float = rotation
var reset_speed:float = 2.0
var damage:int = 1
var enemies_in_range
@onready var timer = %Timer
var mode:String = 'ranged'
var cooldown:bool = false

func _physics_process(delta):
	enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)
	else:
		reset_position(delta)
		
func reset_position(delta):
		if abs(rotation - static_position) < 0.05:
			rotation = static_position
		else:
			rotation = lerp_angle(rotation, static_position, reset_speed*delta)
			
func attack(is_manual: bool = false):
	const BULLET = preload("res://attacks/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.damage = damage
	new_bullet.global_transform = %ShootingPoint.global_transform
	
	%ShootingPoint.add_child(new_bullet)


#if there are enemies shoot
func _on_timer_timeout():
	if enemies_in_range.size() > 0 and not cooldown:
		attack()
