extends Node2D


@export var spawn_radius = 1000
@export var mob:PackedScene
const SLIME:PackedScene = preload("res://slime.tscn")
var mobcounter:int = 0
@export var tree_scenes: Dictionary = {
	"pine_tree": preload("res://pine_tree.tscn"),
}
@export var tree_radius: float = 2500.0
@export var tree_count: int = 100


@onready var player = %Player
@onready var expbar = %ExpBar
@onready var pause_menu = %Pause

var trees = treefunctions.new()

#can change starting spawned mob
func _ready():
	mob = SLIME
	trees.gencheck_trees(player,tree_radius,tree_count,tree_scenes,self)


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pause()
		


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


