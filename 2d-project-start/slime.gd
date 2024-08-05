extends CharacterBody2D
#@export var slime:Node2D
@onready var player = get_node("/root/Game/Player")
@onready var Slime = get_node("Slime")
func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300
	move_and_slide()

func _process(_delta):
	#animation
	if velocity.length() > 0.0:
		Slime.play_walk()
	else:
		Slime.play_hurt()

