extends CharacterBody2D
@export var happy_boo:Node2D
@export var weapon:Area2D
signal health_depleted


#stats
var maxhealth:float = 100.0
var health:float = 100.0
const SPEED:float = 600.0
const DAMAGE_RATE:float = 5.0
const ACCELERATION = 300

#random movement
var state = "IDLE"
const TOLERANCE = 4.0
var min_x:float = 1
var min_y:float = 1
var max_x:float = 1
var max_y:float = 1
var start_position:Vector2 = global_position
var target_position:Vector2 = global_position
var enemies_in_range
#var direction = Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))

func _physics_process(delta:float):
	#direction
	if Input.is_anything_pressed():
		var direction = Input.get_vector("move_left", "move_right","move_up","move_down")
		velocity = direction * SPEED
		state = "MOVING"
	else:
		enemies_in_range = weapon.get_overlapping_bodies()
		if enemies_in_range.size() > 0:
			state = "FIGHT" 
			velocity = Vector2.ZERO
		else:
			if state == "FIGHT" or state == "MOVING":
				state="IDLE"
				velocity = Vector2.ZERO
			wander_ai(delta)
		
		
	move_and_slide()
	
	
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%HealthBar.value = health
		if health <= 0.0:
			health_depleted.emit()

#animations are more smooth in _process instead of _physics_process
func _process(_delta):
	#animation
	if velocity.length() > 0.0:
		happy_boo.play_walk_animation()
	else:
		happy_boo.play_idle_animation()

func update_target_position():
	var target_vector = Vector2(randf_range(-32, 32), randf_range(-32, 32))
	target_position = start_position + target_vector

func is_at_target_position(): 
	# Stop moving when at target +/- tolerance
	return (target_position - global_position).length() < TOLERANCE

func accelerate_to_point(point, acceleration_scalar):
	var direction = (point - global_position).normalized()
	var acceleration_vector = direction * acceleration_scalar
	accelerate(acceleration_vector)

func accelerate(acceleration_vector):
	velocity += acceleration_vector
	velocity = velocity.limit_length(SPEED)

#thanks to: https://forum.godotengine.org/t/making-an-ai-that-randomly-moves/18839
func wander_ai(delta):
	match state:
		"IDLE":
			update_target_position()
			state = "WANDER"
		"WANDER":
			accelerate_to_point(target_position, ACCELERATION*delta)
			if is_at_target_position():
				state="IDLE"

func level_up():
	maxhealth += 20
	%HealthBar.max_value= maxhealth
	%HealthBar.value= maxhealth
	health = maxhealth
