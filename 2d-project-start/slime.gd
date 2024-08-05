extends CharacterBody2D
#@export var slime:Node2D
var health = 3


@onready var player = get_node("/root/Game/Player")
@onready var Slime = %Slime

func _ready():
	Slime.play_walk()


func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300
	move_and_slide()

func take_damage():
	health -= 1
	Slime.play_hurt()
	if health <= 0:
		queue_free()
