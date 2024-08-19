extends CharacterBody2D

class_name Mob

signal dead(data: String, experience: int, scene)

@export var mob_data: MobData

var animationcontainer
const PICKUP_SCENE = preload("res://items/pickup.tscn")
const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")


#STATS 
var health: int = 3
var experience: int = 10
var damage: float = 5.0
var speed: float = 300.0
var idle_speed: float = 200.0
var tolerance: float = 10.0
var targeting_range: float = 500.0
var min_movement_range: float = 400.0
var max_movement_range: float = 1000.0
var loot_table: Dictionary

var target: Node2D
var status: String = "IDLE"

var lastdistance:float = 0
var stuckcounter:int = 0
@onready var idle_timer:Timer = $idle_timer

var stuck_time_threshold:float = 1.0  # Time in seconds before considering the slime "stuck"
var stuck_timer:float = 0.0
var previous_position = Vector2.ZERO  
var movement_threshold:float = 2.0  
var current_idle_target_position:Vector2


func _ready():
	if mob_data:
		health = mob_data.health
		experience = mob_data.experience
		damage = mob_data.damage
		speed = mob_data.speed
		idle_speed = mob_data.idle_speed
		tolerance = mob_data.tolerance
		targeting_range = mob_data.targeting_range
		min_movement_range = mob_data.min_movement_range
		max_movement_range = mob_data.max_movement_range
		loot_table = mob_data.loot_table

func movetotarget(targ,spd):
	var direction = global_position.direction_to(targ.global_position)
	velocity = direction * spd 

func move(pos,spd):
	velocity = global_position.direction_to(pos) * spd
	

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

func take_damage(dmg:int):
	health -= dmg
	animationcontainer.play_hurt()
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
	var movement_vector:Vector2 = Vector2(randf_range(-min_movement_range, max_movement_range), randf_range(-min_movement_range, max_movement_range))
	var final_position:Vector2 = global_position + movement_vector
	return final_position		
