extends InventoryData

class_name InventoryDataEquip

var Slot  = {
	0:"Head",
	1:"Shoulders",
	2:"Body",
	3:"Belt",
	4:"Legs", 
	5:"Feet",
	6:"Ring",
	7:"Amulet",
	8:"Weapon",
	9:"Offhand",
	10:"Cape",
	11:"Hands",
	12:"HeadAccessory",
	13:"Underwear",
	14:"Charm"
}

#create a super function
func drop_slot_data(grabbed_slot_data: SlotData, index:int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataEquip:
		return grabbed_slot_data
	
	#IF THE ITEM SLOT INDEX (SO FOR EXAMPLE FIRST SLOT IS 0) IS EQUAL TO THE ENUM IN \
	#THE EQUIP DATA (SO FOR EXAMPLE HEAD IS 0), LET THE EQUIP BE EQUIPPED
	if grabbed_slot_data.item_data is ItemDataEquip:
		if index == grabbed_slot_data.item_data.eqslot:
			#print(grabbed_slot_data.item_data.eqslot)
			PlayerManager.equipped_item(grabbed_slot_data.item_data)
			return super.drop_slot_data(grabbed_slot_data,index)

	return grabbed_slot_data
	
func drop_single_slot_data(grabbed_slot_data: SlotData, index:int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataEquip:
		return grabbed_slot_data
	
	return super.drop_single_slot_data(grabbed_slot_data,index)


func grab_slot_data(index:int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		PlayerManager.unequipped_item(slot_data.item_data)
		return super.grab_slot_data(index)
	else:
		return null
