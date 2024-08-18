extends Control

@onready var item_texture: TextureRect = $Control/ItemTexture
@onready var item_stats_label: RichTextLabel = $ItemStatsLabel
@onready var currency_available: Label = $Currency_available
@onready var reroll_button: Button = $RerollButton


var noequip:bool = false
var equiplist:Array[SlotData] # list of equip items in inventory
var shards:SlotData #currency for rerolling
var equipselected:int = 0

var tiers:Dictionary = {
	1:[0,10],
	2:[11,20],
	3:[21,30]
}




#change selected equip item
func _on_left_button_pressed() -> void:
	if(equiplist.size() > 1):
		if equipselected > 0:
			equipselected -= 1
			change_item(equipselected)
		else:
			equipselected = equiplist.size()-1
			change_item(equipselected)

func _on_right_button_pressed() -> void:
	if(equiplist.size() > 1):
		if equipselected < equiplist.size()-1:
			equipselected += 1
			change_item(equipselected)
		else:
			equipselected = 0
			change_item(equipselected)

func change_item(index):
	noequip = false
	item_texture.texture = equiplist[index].item_data.texture 
	item_stats_label.clear()
	var custom_string = ""
	for key in equiplist[index].item_data.stats.keys():
		if(equiplist[index].item_data.stats[key] != 0):
			custom_string += str(key) + ": " + str(equiplist[index].item_data.stats[key]) + "\n"
	item_stats_label.add_text(custom_string)

#if no equip items in inventory
func empty():
	item_texture.texture = null
	item_stats_label.clear()
	item_stats_label.add_text("No equip items in inventory!")
	noequip = true
	reroll_button.disabled = true

func set_available_currency():
	if shards:
		if shards.quantity > 0:
			currency_available.text = "Shards: " + str(shards.quantity)
			reroll_button.disabled = false
	else:
		currency_available.text = "No currency!"
		reroll_button.disabled = true

#this gets an array with all itemdataequip from the player inventory. could also be changed to target also the ones equipped
func update_equiplist(equiparray:Array[SlotData],inv_shards:SlotData,update_shards=false):
	if update_shards:
		shards = inv_shards
		set_available_currency()
	else:
		equiplist = equiparray
		equipselected = 0
		shards = inv_shards
		set_available_currency()
		if equiplist:
			change_item(equipselected)
		else:
			empty()
		#print(equiplist)
	

func _on_reroll_button_pressed() -> void:
	if not noequip and shards.quantity > 0:
		#print("rerolled!",equiplist[equipselected])
		shards.set_quantity(shards.quantity - 1) 
		set_available_currency()
		reroll_item(equiplist[equipselected])
		change_item(equipselected)
		PlayerManager.request_inventory_update()

func reroll_item(item):
	#print(item.item_data.stats)
	var possibleStats:Array[String]
	for key in item.item_data.stats.keys():
		item.item_data.stats[key] = 0
		possibleStats.append(key)
	var modifiers_number = randi_range(1,5) #number of stats that will be modified
	#for each modifier, select which stat it will be and the tier and then roll
	for i in range(modifiers_number):
		var selected_stat = randi_range(0, possibleStats.size()-1)
		var tier = randi_range(1,tiers.size()) #roll the tier of the modifier
		var roll = randi_range(tiers[tier][0],tiers[tier][1]) #get the rolls that can happen in that tier
		item.item_data.stats[possibleStats[selected_stat]] = roll
		possibleStats.remove_at(selected_stat)
		
