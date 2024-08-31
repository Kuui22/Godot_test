extends Area2D

@onready var static_position: float = rotation
var reset_speed: float = 2.0
var damage: int = 1
var enemies_in_range
@onready var timer: Timer = %Timer
@onready var weapon_pivot: Marker2D = %Weapon_pivot
@onready var weapon_initial_position: Vector2 = %Weapon_pivot.position  # Initial position of weapon
@onready var weapon_collision: CollisionShape2D = %Weapon_collision
var is_attacking: bool = false  # To keep track of attack state
var thrust_distance: float = 100  # Distance to thrust
var thrust_time: float = 0.2  # Time to complete the thrust
var enemies_hit: Dictionary = {}

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
		rotation = lerp_angle(rotation, static_position, reset_speed * delta)
	weapon_pivot.position = lerp(weapon_pivot.position, weapon_initial_position, delta * reset_speed)
	is_attacking = false
	weapon_collision.disabled = true
	enemies_hit.clear()  # Clear the hit enemies for the next attack


func attack():
	if is_attacking:
		return
	is_attacking = true
	weapon_collision.disabled = false
	enemies_hit.clear()  # Clear the hit enemies for this attack
	
	var tween = create_tween()
	tween.tween_property(weapon_pivot, "position", 
		weapon_initial_position + Vector2(thrust_distance, 0).rotated(rotation), 
		thrust_time / 2).set_ease(Tween.EASE_OUT)
	tween.tween_property(weapon_pivot, "position", 
		weapon_initial_position, 
		thrust_time / 2).set_ease(Tween.EASE_IN)
	
	await tween.finished
	reset_position(thrust_time)
	
	
func _on_timer_timeout():
	# Perform the melee attack
	if enemies_in_range.size() > 0:
		attack()


func _on_weapon_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not enemies_hit.has(body):
		body.take_damage(damage)
		enemies_hit[body] = true
