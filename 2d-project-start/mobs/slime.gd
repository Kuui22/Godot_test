extends CharacterBody2D
#@export var slime:Node2D

#signals

signal dead(data:String,experience:int,scene)

#onready and consts
@onready var player = get_node("/root/Game/Player")
#get_tree().get_nodes_in_group("player")
@onready var Slime = %Slime
const PICKUP_SCENE = preload("res://items/pickup.tscn")
const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
const mob_name:String = "Slime"
const SPEED:float = 300

#stats

var health:int = 3
var experience:int = 10
@export var DAMAGE:float = 5.0

#loot
var loot_table

#status

var target
@export var has_target:bool = false
var status = "RUNNING"
var current_idle_target_position:Vector2 = update_random_position()
@export var min_range:float = 400.0
@export var max_range:float = 1000.0




func movetotarget(targ,speed):
	var direction = global_position.direction_to(targ.global_position)
	velocity = direction * speed 

func move(pos,speed):
	velocity = global_position.direction_to(pos) * speed

#can change base target here
func _ready():
	Slime.play_walk()
	#target = player
	loot_table = ItemDB.get_loot_table(mob_name)

func _physics_process(_delta):
	if(target):
		movetotarget(target,SPEED)
	else:
		if(status == "RUNNING"):
			status_check()
		else:
			current_idle_target_position = update_random_position()
			status = "RUNNING"
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


@export var speed:float = 300.0
@export var tolerance:float = 10.0

func status_check():
	var target_pos:Vector2 = current_idle_target_position
	var distance:float = global_position.distance_to(target_pos)
	
	if distance < tolerance:
		move(target_pos,0)
		status = "FINISHED"
		print("FINISHED")
	
	else:
		move(target_pos,speed)
		status = "RUNNING"
		
func update_random_position():
	var movement_vector:Vector2 = Vector2(randf_range(-min_range, max_range), randf_range(-min_range, max_range))
	var final_position:Vector2 = global_position + movement_vector
	return final_position
