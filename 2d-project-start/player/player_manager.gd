extends Node

signal statsupdated()
signal valuesupdated()
signal equipupdated()
signal openmenu(menu)


var player
var equip_inventory



func initequip(inventory: InventoryData) -> void:
	for slot_data in inventory.slot_datas:
		if(slot_data and slot_data.item_data is ItemDataEquip):
			player.equip(slot_data.item_data.defence)
	statsupdated.emit()

func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)
	
#reminder to change item_data.defence into a dict or some shit with multiple values when using multiple values
#thank you reminder you saved mah laif
func equipped_item(item_data: ItemData) -> void:
	if(item_data is ItemDataEquip):
		player.equip(item_data.stats)
		statsupdated.emit()

func unequipped_item(item_data: ItemData) -> void:
	if(item_data is ItemDataEquip):
		player.unequip(item_data.stats)
		statsupdated.emit()
#if equip inventory of that slot has already something then... else...
func swap_equip(slot_data: SlotData) -> SlotData:
	if(slot_data.item_data is ItemDataEquip):
		var equipslot = slot_data.item_data.eqslot
		var targetslot = player.equip_inventory_data.slot_datas[equipslot]
		if(targetslot):
			#print("there's an equip already")
			player.unequip(targetslot.item_data.stats)
			player.equip(slot_data.item_data.stats)
			player.equip_inventory_data.slot_datas[equipslot] = slot_data
			statsupdated.emit()
			equipupdated.emit()
			return targetslot
		else:
			#print("no equip in that slot")
			player.equip(slot_data.item_data.stats)
			player.equip_inventory_data.slot_datas[equipslot] = slot_data
			statsupdated.emit()
			equipupdated.emit()
			return null
		#slot_data.item_data.eqslot
		#print(player.equip_inventory_data.slot_datas[0].item_data.name)
	else:
		return slot_data
func level_up():
	player.statsdict['MaxHealth'] += 20
	player.healthbar.max_value= player.statsdict['MaxHealth']
	player.healthbar.value= player.statsdict['MaxHealth']
	player.health = player.statsdict['MaxHealth']
	statsupdated.emit()


func valuechange(value:String, amount:int) -> void:
	player.valueupdate(value,amount)
	valuesupdated.emit()
	
func get_global_position() -> Vector2:
	return player.global_position

func open_menu(menu):
	openmenu.emit(menu)

func toggle_auto():
	player.automode = not player.automode
	if(player.automode):
		player.update_target_position()
