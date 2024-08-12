extends Control

@onready var inventory:inv = preload("res://inventory/player_inv.tres")
@onready var slots:Array = $NinePatchRect/GridContainer.get_children()
var is_open:bool = false

var dragged_item: inv_slot = null
var dragged_item_visual: Sprite2D = null


func _ready():
	inventory.update.connect(update_slots)
	update_slots()
	close()

func update_slots():
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])
		slots[i].slotclicked.connect(on_slot_clicked)
	
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if(is_open):
			close()
		else:
			open()
		if dragged_item_visual != null:
			dragged_item_visual.position = get_global_mouse_position()
			
	
func close():
	visible = false
	is_open = false
func open():
	visible = true
	is_open = true
func on_slot_clicked(index:int, button:int):
	if button == MOUSE_BUTTON_LEFT:
		if dragged_item == null:
			# Pick up the item
			dragged_item = inventory.slots[index]
			inventory.slots[index] = inv_slot.new()  # Empty the slot
			dragged_item_visual = Sprite2D.new()
			dragged_item_visual.texture = dragged_item.item.texture
			add_child(dragged_item_visual)
			update_slots()
		else:
			# Place the item back in a slot if possible
			if inventory.slots[index].item == null:
				inventory.slots[index] = dragged_item
				dragged_item = null
				remove_child(dragged_item_visual)
				dragged_item_visual.queue_free()
				dragged_item_visual = null
				update_slots()

