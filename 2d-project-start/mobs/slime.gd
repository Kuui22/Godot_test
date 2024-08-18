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

#stats

var health:int = 3
var experience:int = 10
@export var DAMAGE:float = 5.0
@export var speed:float = 300.0
@export var idle_speed:float = 200.0
@export var tolerance:float = 10.0
@export var targeting_range:float = 500.0
#loot
var loot_table

#status

var target
@export var has_target:bool = false
var status = "RUNNING"
var current_idle_target_position:Vector2 = update_random_position()
@export var min_range:float = 400.0
@export var max_range:float = 1000.0
var lastdistance:float = 0
var stuckcounter:int = 0
@onready var idle_timer:Timer = $idle_timer

var stuck_time_threshold = 1.0  # Time in seconds before considering the slime "stuck"
var stuck_timer = 0.0
var previous_position = Vector2.ZERO  
var movement_threshold = 2.0  


func movetotarget(targ,spd):
	var direction = global_position.direction_to(targ.global_position)
	velocity = direction * spd 

func move(pos,spd):
	velocity = global_position.direction_to(pos) * spd

#can change base target here
func _ready():
	Slime.play_walk()
	target = player
	loot_table = ItemDB.get_loot_table(mob_name)

func _physics_process(delta):
	# IF MOB HAS A TARGET AND TARGET IS IN RANGE
	if(target and global_position.distance_to(target.global_position) < targeting_range ):
		movetotarget(target,speed)
		status = "FIGHTING"
	else:
		#IF MOB IS ALREADY IDLE MOVING TO A RANDOM PLACE
		if(status == "RUNNING"):
			status_check()
		else:
			#MOB WAITS (1 TO 2) SECONDS AND IDLE MOVES
			#move(Vector2.ZERO,0)
			if idle_timer.is_stopped():
				idle_timer.wait_time = randf_range(1,2)
				idle_timer.start()
				await idle_timer.timeout
				current_idle_target_position = update_random_position()
				status = "RUNNING"
	previous_position = global_position
	move_and_slide()

#slimes get stuck between themselves so try to bounce them if they get stuck while random walking
	if is_stuck(previous_position, delta) and status == "RUNNING":
		apply_strong_repulsion()
		current_idle_target_position = update_random_position()

func is_stuck(prev_pos, delta):
	var distance_moved = global_position.distance_to(prev_pos)
	if distance_moved < movement_threshold:
		stuck_timer += delta
		if stuck_timer >= stuck_time_threshold:
			return true
			
	else:
		stuck_timer = 0.0  # Reset the stuck timer if movement is detected
	return false

func apply_strong_repulsion():
	var mobs = get_tree().get_nodes_in_group("mobs")
	for mob in mobs:
		if mob != self:
			var direction = global_position - mob.global_position
			var distance = direction.length()
			if distance < 500:  # Adjust this range as needed
				var repulsion_force = direction.normalized() * 1500  # Strong repulsion force
				velocity += repulsion_force
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
		if drop is ItemDataEquip: #equip needs to be duplicated or stats are shared
			loot.slot_data.item_data = drop.duplicate()
		else: #other stuff no or it won't stack
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

func status_check():
	var target_pos:Vector2 = current_idle_target_position
	var distance:float = global_position.distance_to(target_pos)

	
	
	if distance < tolerance:
		move(target_pos,0)
		status = "FINISHED"
		#print("FINISHED")
	
	else:
		move(target_pos,idle_speed)
		status = "RUNNING"

		


func update_random_position():
	var movement_vector:Vector2 = Vector2(randf_range(-min_range, max_range), randf_range(-min_range, max_range))
	var final_position:Vector2 = global_position + movement_vector
	return final_position
