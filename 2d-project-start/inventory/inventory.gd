extends Resource

class_name inv

signal update

@export var slots:Array[inv_slot]

func insert(item:inv_item):
	#returns slot where item == item
	var itemslots = slots.filter(func(slot): return slot.item == item)
	if !itemslots.is_empty():
		itemslots[0].amount +=1
	else:
		#returns empty slot
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount = 1
		else:#inventory full
			pass
	update.emit()
