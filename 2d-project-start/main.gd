extends Node2D

const PickUp = preload("res://items/pickup.tscn")

@export var spawn_radius = 1200
#change these if map size is changed
var boundx:Array[float] =[-9400, 9400]
var boundy:Array[float] = [-9400, 9400]
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
@onready var player_stats = %PlayerStats

#crafting variables
@onready var crafting_menu: Control = %CraftingMenu
@onready var reroll_inventory: Control = crafting_menu.get_node("TabContainer/RerollEquip")

var old_inventory_equips:Array[SlotData]
var old_shard_amount:int



#can change starting spawned mob
func _ready():
	#player + inventory
	player.toggle_inventory.connect(toggle_inventory_interface)
	player_stats.populate_stats_ui(player.statsdict)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	inventory_interface.set_equip_inventory_data(player.equip_inventory_data)
	inventory_interface.force_close.connect(toggle_inventory_interface)
	PlayerManager.statsupdated.connect(updatestats)
	PlayerManager.equipupdated.connect(updateequip)
	PlayerManager.initequip(player.equip_inventory_data)
	PlayerManager.openmenu.connect(open_menus)
	PlayerManager.set_xp_bar(expbar)
	
	#crafting connections
	player.inventory_data.inventory_updated.connect(get_player_inventory_equip)
	#PlayerManager.equipupdated.connect(get_player_inventory_equip)
	get_player_inventory_equip("")
	
	#objects
	mob = SLIME
	#TreeFunctions.check_and_generate_trees(player,tree_radius,tree_count,tree_scenes,self)
	BiomeGenerator.generate_biome()
	
	
	#get all current external inventories
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)
		

func _unhandled_key_input(_event):
	if Input.is_action_just_pressed("pause"):
		pause()
	if Input.is_action_just_pressed("characterstats"):
		toggle_stats_interface()
	if Input.is_action_just_pressed("craftingmenu"):
		toggle_crafting_interface()
		
func updatestats(_x = null) -> void:
	player_stats.update_stats_ui(player.statsdict)

func updateequip(_x = null) -> void:
	inventory_interface.set_equip_inventory_data(player.equip_inventory_data)

func get_player_inventory_equip(_inv):
	var itemarray:Array[SlotData] = []
	var reroll_shards:SlotData
	var shard_amount:int
	for item in player.inventory_data.slot_datas:
		if item:
			if item.item_data is ItemDataEquip:
				print(item.item_data.name)
				itemarray.append(item)
			elif item.item_data.name == "RandShard":
				reroll_shards = item
				shard_amount = item.quantity
	if old_inventory_equips:
		#print("it exists")
		if old_inventory_equips == itemarray:
			#print("Inventory is the same")
			if shard_amount == old_shard_amount:
				#print("Shards are the same")
				return
			else:
				#print("Different shards")
				reroll_inventory.update_equiplist(itemarray,reroll_shards,true)
				old_shard_amount = shard_amount
		else:
			reroll_inventory.update_equiplist(itemarray,reroll_shards)
			old_inventory_equips = itemarray
			old_shard_amount = shard_amount
	else:
		reroll_inventory.update_equiplist(itemarray,reroll_shards)
		old_inventory_equips = itemarray
		old_shard_amount = shard_amount
		
func toggle_inventory_interface(external_inventory_owner = null) -> void:
	#this flips the value each time this is called
	inventory_interface.visible = not inventory_interface.visible
	
	if external_inventory_owner and inventory_interface.visible: 
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()
func toggle_stats_interface() -> void:
	player_stats.visible = not player_stats.visible
func toggle_crafting_interface() -> void:
	crafting_menu.visible = not crafting_menu.visible

func pause():
	if Engine.time_scale == 0:
		Engine.time_scale = 1
		pause_menu.visible = false
	else:
		Engine.time_scale = 0
		pause_menu.visible = true

func _on_tree_timer_timeout():#every x seconds as timer check if it has to generate trees
	TreeFunctions.gencheck_trees(player,tree_radius,tree_count,tree_scenes,self)
	
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
	var new_mob = MobContainer.spawn_mob(1,"slime")
	var new_position = player.global_position + mob_position
	#avoid going out of bounds
	var clamped_x = clampf(new_position.x, boundx[0], boundx[1])
	var clamped_y = clampf(new_position.y, boundy[0], boundy[1])
	new_mob.global_position = Vector2(clamped_x, clamped_y)
	new_mob.name = "slime_%d" % mobcounter
	add_child(new_mob)
	new_mob.dead.connect(_on_mob_killed)

#player is dd
func _on_player_health_depleted():
	%GameOver.visible = true
	get_tree().paused = true

#a mob spawned is dd
func _on_mob_killed(data,experience,nmob):
	mobcounter-=1
	#print(data)
	expbar.value += experience
	nmob.dead.disconnect(_on_mob_killed)
	if expbar.value >= expbar.max_value:
		#get_tree().paused = true
		PlayerManager.level_up(expbar)

#drop items
func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up = PickUp.instantiate()
	pick_up.slot_data = slot_data
	pick_up.global_position = player.get_drop_position()
	add_child(pick_up)

#open menus based on item used
func open_menus(menu):
	match menu:
		"RANDOMIZER":
			crafting_menu.visible = true
			pass


func _on_auto_mode_pressed() -> void:
	PlayerManager.toggle_auto()
