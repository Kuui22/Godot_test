extends Node
var player
#playermanager will be the interface between other scripts and updating player values.
#i know it adds a layer but i like to have the functions here
func get_global_position() -> Vector2:
	return player.global_position
