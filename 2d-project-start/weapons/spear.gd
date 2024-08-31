extends Area2D

var mode = 'melee'


@onready var static_position: float = rotation
var reset_speed: float = 2.0
var damage: int = 1
var attackspeed: float = 1
var enemies_in_range
@onready var weapon_pivot: Marker2D = %Weapon_pivot
@onready var weapon_initial_position: Vector2 = %Weapon_pivot.position  # Initial position of weapon
@onready var weapon_collision: CollisionShape2D = %Weapon_collision
var is_attacking: bool = false  # To keep track of attack state
var thrust_distance: float = 100  # Distance to thrust
var base_thrust_time: float = 0.5  # Time to complete the thrust
var enemies_hit: Dictionary = {}
var manual_mode: bool = true
var tween:Tween



func _physics_process(delta):
	if is_attacking:
		return
	if manual_mode:
		look_at(get_global_mouse_position())
	else:
		enemies_in_range = get_overlapping_bodies()
		if enemies_in_range.size() > 0:
			var target_enemy = enemies_in_range.front()
			look_at(target_enemy.global_position)
			attack()
		else:
			reset_position(delta)

func toggle_mode():
	manual_mode = !manual_mode
	if manual_mode:
		pass
	else:
		pass



func reset_position(delta,tween_call=false):
	if tween:
		if not manual_mode and not tween.is_running() and not tween_call:
			if abs(rotation - static_position) < 0.05:
				rotation = static_position
			else:
				rotation = lerp_angle(rotation, static_position, reset_speed * delta)
	
	weapon_pivot.position = weapon_initial_position
	is_attacking = false
	weapon_collision.disabled = true
	enemies_hit.clear()


func attack(is_manual: bool = false):
	if is_attacking:
		return
	is_attacking = true
	weapon_collision.disabled = false
	enemies_hit.clear()
	
	var attack_direction = Vector2.RIGHT.rotated(rotation)
	if is_manual:
		attack_direction = (get_global_mouse_position() - global_position).normalized()
		rotation = attack_direction.angle()
	
	if tween:
		if tween.is_running():
			tween.stop()
		
	var start_pos = weapon_pivot.position
	var end_pos = start_pos + (attack_direction * thrust_distance).rotated(-rotation)
	var thrust_time = base_thrust_time / attackspeed
	
	tween = create_tween()
	tween.tween_property(weapon_pivot, "position", end_pos, thrust_time / 2).set_ease(Tween.EASE_OUT)
	tween.tween_property(weapon_pivot, "position", start_pos, thrust_time / 2).set_ease(Tween.EASE_IN)
	
	await tween.finished
	reset_position(thrust_time,true)
	



func _on_weapon_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not enemies_hit.has(body):
		body.take_damage(damage)
		enemies_hit[body] = true
