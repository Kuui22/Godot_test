extends CharacterBody2D
#@export var slime:Node2D
var health:int = 3
var experience:int = 5
signal dead(data:String,experience:int,scene)

@onready var player = get_node("/root/Game/Player")
@onready var Slime = %Slime
@export var DAMAGE:float = 5.0

var target
const SPEED:float = 300
const SPEEDFACTOR:float = 50

#can change base target here
func _ready():
	Slime.play_walk()
	target = player


func _physics_process(delta):
	if(target):
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * SPEED * delta * SPEEDFACTOR
	else:
		pass
	move_and_slide()

#getting hit
func take_damage():
	health -= 1
	Slime.play_hurt()
	if health <= 0:
		dead.emit("Im dead",experience,self)
		queue_free()
		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		
