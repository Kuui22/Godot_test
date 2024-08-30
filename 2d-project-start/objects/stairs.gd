extends Node2D

signal use_stairs(stairs)


func player_interact() -> void:
	use_stairs.emit(self)
	
func stop_player_interact() -> void:
	use_stairs.emit(self)
