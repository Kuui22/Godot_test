extends Node

@onready var sprite = $Sprite2D
@onready var pickup_range = $pickup_range
@export var item:inv_item :
	get:
		return item
	set(value):
		item = value
		

var player = null

func _ready():
	if item and item.texture:
		sprite.texture = item.texture
	

func _on_pickup_range_body_entered(body):
	if body.has_method("collect"):
		#print("Helloooo")
		player = body
		player.collect(item)
		queue_free()
