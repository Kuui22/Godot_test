extends CharacterBody2D

signal health_depleted

var health:float = 100.0


@export var happy_boo:Node2D
const SPEED:float = 600.0
const DAMAGE_RATE:float = 5.0

func _physics_process(delta:float):
	#direction
	var direction = Input.get_vector("move_left", "move_right","move_up","move_down")
	velocity = direction * SPEED
	move_and_slide()
	
	
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%HealthBar.value = health
		if health <= 0.0:
			health_depleted.emit()
	
func _process(_delta):
	#animation
	if velocity.length() > 0.0:
		happy_boo.play_walk_animation()
	else:
		happy_boo.play_idle_animation()


