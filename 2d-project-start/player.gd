extends CharacterBody2D
@export var happy_boo:Node2D
@export var weapon:Area2D
signal health_depleted
signal toggle_inventory()


@onready var interact_range = $InteractRange
var interactables = null
var interacting:bool = false

@onready var healthbar = %HealthBar
@onready var currentweapon = %Weapon


#stats
var Stats:Character = Character.new() :
	get: return Stats
	set(value):
		Stats = value

var currenthealth:float = Stats.currenthealth
const MAX_AI_SPEED:float = 450.0
const SPEEDFACTOR:float = 50
const DAMAGE_RATE:float = 5.0
const ACCELERATION = 300
const defence_multiplier:float = 0.05

@export var statsdict:Dictionary = {
	"Level":Stats.level,
	"MovementSpeed":Stats.speed,
	"MaxHealth":Stats.maxhealth,
	"Defence":Stats.defence,
	"Attack":Stats.attack,
	"AttackSpeed":Stats.baseattackspeed
	}
var coins:int 
var diamonds:int
@export var valuesdict:Dictionary = {
	"Coins":coins,
	"Diamonds":diamonds
	}


#inventory
@export var inventory_data:InventoryData
@export var equip_inventory_data: InventoryDataEquip

var automode:bool = false
#random movement
var state = "IDLE"
const DAMPING:float = 0.5
const TOLERANCE = 4.0
var min_x:float = 1
var min_y:float = 1
var max_x:float = 1
var max_y:float = 1
var start_position:Vector2 = global_position
var target_position:Vector2 = global_position
var enemies_in_range
#movement stuck variables
var stuck_time:float = 0.0
var stuck_threshold:float = 2.0 #movement 
var stuck_timeout:float = 2.0 #time
var previous_position:Vector2


func _ready():
	PlayerManager.player = self
	updateweapon()

func _physics_process(delta:float):
	#direction
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):#player input
		var direction = Input.get_vector("move_left", "move_right","move_up","move_down")
		velocity = direction * statsdict['MovementSpeed'] 
		state = "MOVING"
	else:#check for enemies
		if(automode):
			enemies_in_range = weapon.get_overlapping_bodies()
			if enemies_in_range.size() > 0:#there are enemies
				state = "FIGHT"
				fight_ai(delta)
			else:#no enemies
				if state == "FIGHT" or state == "MOVING":
					state="IDLE"
					velocity = velocity.move_toward(Vector2.ZERO, DAMPING * delta * statsdict['MovementSpeed'])
				if ai_is_stuck(delta):
					state = "IDLE"
				wander_ai(delta)
		else:
			velocity = Vector2.ZERO * 0
		
	previous_position = global_position
	move_and_slide()
	
	#take damage from mobs
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		currenthealth -= DAMAGE_RATE * overlapping_mobs.size() * delta /(1+statsdict['Defence']*defence_multiplier)
		%HealthBar.value = currenthealth
		if currenthealth <= 0.0:
			health_depleted.emit()

#animations are more smooth in _process instead of _physics_process? or so they told me
func _process(_delta):
	#animation
	if velocity.length() > 0.0:
		happy_boo.play_walk_animation()
	else:
		happy_boo.play_idle_animation()


func _unhandled_input(_event):
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()


#functions for wandering ai
func update_target_position():
	var target_vector = Vector2(randf_range(-512, 512), randf_range(-512, 512))
	target_position = previous_position + target_vector

func is_at_target_position(): 
	#stop moving when at target +/- tolerance
	return (target_position - global_position).length() < TOLERANCE

func accelerate_to_point(point, acceleration_scalar):
	var direction = (point - global_position).normalized()
	var acceleration_vector = direction * acceleration_scalar
	accelerate(acceleration_vector)
func accelerate_away_from_point(point, acceleration_scalar):
	var direction = (global_position - point ).normalized()
	var acceleration_vector = direction * acceleration_scalar
	accelerate(acceleration_vector)

func accelerate(acceleration_vector):
	velocity += acceleration_vector
	velocity = velocity.limit_length(MAX_AI_SPEED)

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

func fight_ai(delta):
	#try to search a point with no enemies
	var avg_enemy_position = Vector2.ZERO
	for enemy in enemies_in_range:
		avg_enemy_position += enemy.global_position
	avg_enemy_position /= enemies_in_range.size()
	#var direction_away = (global_position - avg_enemy_position).normalized()
	accelerate_away_from_point(avg_enemy_position, ACCELERATION * delta)

func ai_is_stuck(delta):
	var distance_moved = global_position.distance_to(previous_position)
	if distance_moved < stuck_threshold:
		stuck_time += delta
		#print(stuck_time)
	else:
		stuck_time = 0.0
	return stuck_time >= stuck_timeout


func interact() -> void:
	if(!interacting):
		interactables = interact_range.get_overlapping_bodies()
		if(interactables.size() > 0):
			interactables[0].get_parent().player_interact()
			interacting = true
	elif(interactables):
		interactables[0].get_parent().stop_player_interact()
		interactables = null
		interacting = false
		
func get_drop_position() -> Vector2:
	var dir = global_position
	return dir+Vector2(60,60)

func collect(_item):
	pass

#TODO: FIX ME LATER
func updateweapon():
	currentweapon.damage = statsdict['Attack']
	if(statsdict['AttackSpeed'] > 0.1):
		currentweapon.timer.wait_time = statsdict['AttackSpeed']
	else:
		currentweapon.timer.wait_time = 0.1
	

#playermanager
#so why a dict? in the future instead of passing a single value pass a dict of the
#attributes of the item: like defence + idk speed? and loop through them and add each to the statistics
#so that we can have multistat items
func equip(stats:Dictionary) -> void:
	for key in stats:
		if statsdict.has(key):
			if(key == "AttackSpeed"):
				statsdict[key] -= stats[key]
			else:
				statsdict[key] += stats[key]
	updateweapon()

func unequip(stats:Dictionary) -> void:
	for key in stats:
		if statsdict.has(key):
			if(key == "AttackSpeed"):
				statsdict[key] += stats[key]
			else:
				statsdict[key] -= stats[key]
	updateweapon()

func valueupdate(value:int) -> void:
	valuesdict['Coins'] += value
