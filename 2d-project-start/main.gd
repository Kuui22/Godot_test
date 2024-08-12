extends Node2D



@export var spawn_radius = 1000
@export var mob:PackedScene
const SLIME:PackedScene = preload("res://mobs/slime.tscn")
var mobcounter:int = 0
@export var tree_scenes: Dictionary = {
	"pine_tree": preload("res://pine_tree.tscn"),
}
@export var tree_radius: float = 2500.0
@export var tree_count: int = 100


@onready var player = %Player
@onready var expbar = %ExpBar
@onready var pause_menu = %Pause
@onready var inventory_interface = %InventoryInterface
var trees = treefunctions.new()

#can change starting spawned mob
func _ready():
	player.toggle_inventory.connect(toggle_inventory_interface)
	mob = SLIME
	trees.gencheck_trees(player,tree_radius,tree_count,tree_scenes,self)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	inventory_interface.force_close.connect(toggle_inventory_interface)
	#get all current external inventories
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)



func _unhandled_input(_event):
	if Input.is_action_just_pressed("pause"):
		pause()

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	#this flips the value each time this is called
	inventory_interface.visible = not inventory_interface.visible
	
	if external_inventory_owner: 
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()


func pause():
	if Engine.time_scale == 0:
		Engine.time_scale = 1
		pause_menu.visible = false
	else:
		Engine.time_scale = 0
		pause_menu.visible = true

func _on_tree_timer_timeout():#every x seconds as timer check if it has to generate trees
	trees.gencheck_trees(player,tree_radius,tree_count,tree_scenes,self)
	
#spawn mobs
'''
connecting to new instantiated scene's signal
#var new_thing = some_thing.instantiate()
#new_thing.signal_name.connect(method_to_call)
'''
func _on_spawn_timer_timeout():
	mobcounter+=1
	var mob_angle:float = randf_range(0.0, TAU)
	var mob_position:Vector2 = Vector2(spawn_radius,0.0).rotated(mob_angle)
	var new_mob = mob.instantiate()
	new_mob.global_position = player.global_position + mob_position
	new_mob.name = "slime_%d" % mobcounter
	add_child(new_mob)
	new_mob.dead.connect(_on_mob_killed)

#player is dd
func _on_player_health_depleted():
	%GameOver.visible = true
	get_tree().paused = true

#a mob spawned is dd
func _on_mob_killed(data,experience,nmob):
	print(data)
	expbar.value += experience
	nmob.dead.disconnect(_on_mob_killed)
	if expbar.value >= expbar.max_value:
		#get_tree().paused = true
		player.level_up()
		expbar.value = 0


