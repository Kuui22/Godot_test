extends CharacterBody2D
#@export var slime:Node2D
var health:int = 3
var experience:int = 10
signal dead(data:String,experience:int,scene)

@onready var player = get_node("/root/Game/Player")
@onready var Slime = %Slime
@export var DAMAGE:float = 5.0
#@export var drops:inv_item 

const PICKUP_SCENE = preload("res://items/pickup.tscn")
const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
const mob_name:String = "Slime"


var loot_table

var target
const SPEED:float = 300
const SPEEDFACTOR:float = 50

func movetotarget(targ,speed):
	var direction = global_position.direction_to(targ.global_position)
	velocity = direction * speed 

	

#can change base target here
func _ready():
	Slime.play_walk()
	target = player
	loot_table = ItemDB.get_loot_table(mob_name)

func _physics_process(_delta):
	if(target):
		movetotarget(target,SPEED)
	else:
		pass
	move_and_slide()

#getting hit
func take_damage(damage:int):
	health -= damage
	Slime.play_hurt()
	if health <= 0:
		dead.emit("Im dead",experience,self)
		queue_free()
		call_deferred("death")
			
func death():
	var smoke = SMOKE_SCENE.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	var loot = PICKUP_SCENE.instantiate()
	var drop = possible_drops()
	if drop:
		loot.slot_data.item_data = drop
		get_parent().add_child(loot)
		loot.global_position = global_position
	else:
		loot.queue_free()
	
func possible_drops():
	var total_weight = 0
	var cumulative_weight = []
	#var selector = randi_range(1,2)
	#var drop = ItemDB.get_item(selector)
	var drop
	for i in loot_table:
		total_weight += int(loot_table[i][2])
		cumulative_weight.append([loot_table[i][1],total_weight])
	var chance = randf_range(0,total_weight)
	for i in cumulative_weight:
		if chance< i[1]:
			print(i)
			drop = ItemDB.get_item(int(i[0]))
			return drop
	return drop
