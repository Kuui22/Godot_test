extends Node2D

signal toggle_inventory(external_inventory_owner)

@export var inventory_data: InventoryData

var player = null
var interactable:bool = false



func player_interact() -> void:
	toggle_inventory.emit(self)
	
func stop_player_interact() -> void:
	toggle_inventory.emit(self)
