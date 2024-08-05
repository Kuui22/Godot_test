extends Node2D

@export var spawn_radius = 1000
@export var mob:PackedScene

const SLIME:PackedScene = preload("res://slime.tscn")

@onready var player = %Player

func _ready():
	mob = SLIME


func _on_spawn_timer_timeout():
	var mob_angle:float = randf_range(0.0, TAU)
	var mob_position:Vector2 = Vector2(spawn_radius,0.0).rotated(mob_angle)
	var new_mob = mob.instantiate()
	new_mob.global_position = player.global_position + mob_position
	add_child(new_mob)


func _on_player_health_depleted():
	%GameOver.visible = true
	get_tree().paused = true
