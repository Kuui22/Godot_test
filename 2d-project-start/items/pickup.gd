extends Node2D

@onready var sprite = $Sprite2D
@onready var pickup_range = $pickup_range
#@export var item:
#	get:
#		return item
#	set(value):
#		item = value
		
@export var slot_data:SlotData = SlotData.new()
@onready var distance_timer:Timer = $Check_distance_timer

func _ready():
	#if item and item.texture:
	#	sprite.texture = item.texture
	sprite.texture = slot_data.item_data.texture
	distance_timer.start()
	distance_timer.wait_time = 10
	distance_timer.timeout.connect(despawn_check)

func _on_pickup_range_body_entered(body):
	if body.has_method("collect"):
		if body.inventory_data.pick_up_slot_data(slot_data):
			queue_free()

func despawn_check():
	var distance = global_position.distance_squared_to(PlayerManager.get_global_position()) 
	if(distance > 20000000):
		print("Distance is:"+str(distance)+",Despawining")
		queue_free()
