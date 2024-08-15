extends Node

@onready var sprite = $Sprite2D
@onready var pickup_range = $pickup_range
#@export var item:
#	get:
#		return item
#	set(value):
#		item = value
		
@export var slot_data:SlotData = SlotData.new()


func _ready():
	#if item and item.texture:
	#	sprite.texture = item.texture
	sprite.texture = slot_data.item_data.texture

func _on_pickup_range_body_entered(body):
	if body.has_method("collect"):
		if body.inventory_data.pick_up_slot_data(slot_data):
			queue_free()
