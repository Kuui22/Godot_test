extends Mob
#@export var slime:Node2D


#onready and consts
@onready var player = get_node("/root/Game/Player")
#get_tree().get_nodes_in_group("player")
#self.animationplayer = %Slime

const mob_name:String = "Slime"

#stats

@export var DAMAGE:float = 5.0

@export var has_target:bool = false


#can change base target here
func _ready():
	super._ready()
	self.animationcontainer = %Slime
	animationcontainer.play_walk()
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
