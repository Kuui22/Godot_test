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

var maxhealth:float = 100.0
var health:float = Stats.health
var speed:float = Stats.speed
var defence:int = 0
var attack:int = 2
const MAX_AI_SPEED:float = 450.0
const SPEEDFACTOR:float = 50
const DAMAGE_RATE:float = 5.0
const ACCELERATION = 300

@export var statsdict:Dictionary = {
	"Speed":speed,
	"MaxHealth":maxhealth,
	"Defence":defence
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
#var direction = Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))


func _ready():
	PlayerManager.player = self
	currentweapon.damage = attack

func _physics_process(delta:float):
	#direction
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):#player input
		var direction = Input.get_vector("move_left", "move_right","move_up","move_down")
		velocity = direction * speed 
		state = "MOVING"
	else:#check for enemies
		enemies_in_range = weapon.get_overlapping_bodies()
		if enemies_in_range.size() > 0:#there are enemies
			state = "FIGHT"
			#try to search a point with no enemies
			var avg_enemy_position = Vector2.ZERO
			for enemy in enemies_in_range:
				avg_enemy_position += enemy.global_position
			avg_enemy_position /= enemies_in_range.size()
			#var direction_away = (global_position - avg_enemy_position).normalized()
			accelerate_away_from_point(avg_enemy_position, ACCELERATION * delta)
		else:#no enemies
			if state == "FIGHT" or state == "MOVING":
				state="IDLE"
				velocity = velocity.move_toward(Vector2.ZERO, DAMPING * delta * speed)
			wander_ai(delta)
		
		
	move_and_slide()
	
	#take damage from mobs
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%HealthBar.value = health
		if health <= 0.0:
			health_depleted.emit()

#animations are more smooth in _process instead of _physics_process
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
	var target_vector = Vector2(randf_range(-32, 32), randf_range(-32, 32))
	target_position = start_position + target_vector

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

func collect(item):
	pass

#playermanager
#so why a dict? in the future instead of passing a single value pass a dict of the
#attributes of the item: like defence + idk speed? and loop through them and add each to the statistics
#so that we can have multistat items
func equip(def_value:int) -> void:
	defence += def_value
	statsdict['Defence'] = defence

func unequip(def_value:int) -> void:
	defence -= def_value
	statsdict['Defence'] = defence

func valueupdate(value:int) -> void:
	coins += value
	valuesdict['Coins'] = coins
