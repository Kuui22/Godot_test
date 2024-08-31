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


func _physics_process(delta):
	enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)
		attack()  # Initiate attack if enemy is in range
	else:
		reset_position(delta)

func reset_position(delta):
	if abs(rotation - static_position) < 0.05:
		rotation = static_position
	else:
		rotation = lerp_angle(rotation, static_position, reset_speed * delta)
	weapon_pivot.position = lerp(weapon_pivot.position, weapon_initial_position, delta * reset_speed)  # Reset weapon position
	is_attacking = false  # Reset attacking state
	weapon_collision.disabled = true  # Disable collision detection when not attacking


func attack():
	if is_attacking:
		return  # Prevent multiple attacks at the same time
	is_attacking = true
	weapon_collision.disabled = false  # Enable collision detection during attack
	# Thrust forward
	weapon_pivot.position = weapon_initial_position + Vector2(thrust_distance, 0).rotated(rotation)
	await get_tree().create_timer(thrust_time).timeout
	# After thrusting, reset position and disable collision
	reset_position(thrust_time)
	weapon_collision.disabled = true
	
	
func _on_timer_timeout():
	# Perform the melee attack
	if enemies_in_range.size() > 0:
		attack()
