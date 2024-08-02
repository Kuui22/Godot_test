extends CharacterBody2D

@export var happy_boo:Node2D
const SPEED:float = 300.0
const JUMP_VELOCITY:float = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity:float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(_delta:float):
	'''
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	'''
	#direction
	var direction = Input.get_vector("move_left", "move_right","move_up","move_down")
	velocity = direction * SPEED
		
	move_and_slide()
func _process(_delta):
	#animation
	if velocity.length() > 0.0:
		happy_boo.play_walk_animation()
	else:
		happy_boo.play_idle_animation()


