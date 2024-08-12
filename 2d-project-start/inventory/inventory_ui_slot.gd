extends Panel

signal slotclicked(index:int, button:int)

@onready var item_visual:Sprite2D = $CenterContainer/Panel/ItemDisplay
@onready var amount_text:Label = $CenterContainer/Panel/Quantity


func update(slot:inv_slot):
	if(slot.item):
		item_visual.visible = true
		amount_text.visible = true
		item_visual.texture = slot.item.texture
		amount_text.text = "x"+str(slot.amount)
	else:
		item_visual.visible = false
		amount_text.visible = false


func _on_gui_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT or MOUSE_BUTTON_RIGHT \
	and event.is_pressed():
		slotclicked.emit(get_index(), event.button_index)
