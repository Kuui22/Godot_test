extends PanelContainer

signal slot_clicked(index:int, button:int)

@onready var texture_rect = $MarginContainer/TextureRect
@onready var quantitylabel = $Quantitylabel

#set slot data takes the item's texture and sets it into the slot, with item's name and description
#into the tooltip instead. If the item has quantity also show quantity.
#on_gui_input takes only the input that happens on it (no shit) and since we have both an use 
#function with rightclick and a moving function with leftclick we send the click and on what slot in the signal

func set_slot_data(slot_data: SlotData) -> void:
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name,item_data.description]
	
	if(slot_data.quantity>1):
		quantitylabel.text= "x%s" % slot_data.quantity
		quantitylabel.show()
	else:
		quantitylabel.hide()
# \ connects new lines it seems?
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
