extends TabBar

#okay so let's note how this works here
#main.gd calls when ready set_player_inventory_data that will set the inventory interface in the main scene
#with the data from the inventory set into the PLAYER. you can find this by clicking on the player that is in the main scene.
#the variable in the player script is inventory_data
#that func (s_p_i_d) calls set_inventory_data func that calls populate_item_grid
#how that works is that p_i_g sets the inventory data (which is an array of slot datas) with slot datas by looping through
#each item that is in the inventory set into the player and creates a texture rect which will contain an image if an item is there
#so what's in each slot? in each slot there is a function to get the item_data of the item that should be in that slot
#and set item_data.texture for the image and .quantity for the amount
#so at this point why not explain also item_data
#each item data contains the name of the item, is it stackable, description , (effect?) and texture



const Slot = preload("res://inventory/slot.tscn")

@onready var itemgrid:GridContainer = $ItemContainer/MarginContainer/Itemgrid
@onready var item_container = $ItemContainer
#@onready var equip_container = $EquipContainer
#@onready var equipgrid = $EquipContainer/MarginContainer/Equipgrid

@onready var inventory = $"."





func set_inventory_data(inventory_data: InventoryData) -> void:
	if(!inventory_data.inventory_updated.is_connected(populate_item_grid)):
		inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)

func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)

func populate_item_grid(inventory_data: InventoryData) -> void:
	for child in itemgrid.get_children():
		child.queue_free()
	#per item in array of slots
	for slot_data in inventory_data.slot_datas:
		var slot = Slot.instantiate()
		itemgrid.add_child(slot)
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		#if not null
		if(slot_data):
			slot.set_slot_data(slot_data)

func changetabs() -> void:
	pass

var lasttab = null
func _on_tab_changed(tab):
		if(inventory.get_parent().visible):
			if (tab == 0):
				if(lasttab):
					lasttab.visible = false
			elif(tab == 1):
				lasttab = inventory.get_parent().find_child('EquipInventory')
				lasttab.visible = true
