extends ItemData

class_name ItemDataEquip

@export var stats: Dictionary= {
	"MovementSpeed":0,
	"MaxHealth":0,
	"Defence":0,
	"Attack":0,
	"AttackSpeed":0.0
}
@export var eqslot:Slot


enum Slot {
	Head,
	Shoulders,
	Body,
	Belt,
	Legs, 
	Feet,
	Ring,
	Amulet,
	Weapon,
	Offhand,
	Cape,
	Hands,
	HeadAccessory,
	Underwear,
	Charm,
	NOT
}
func _init():
	_update_description()

# Function to dynamically update the description based on stats
func _update_description() -> void:
	description = "Stats:\n"
	for stat in stats.keys():
		if stats[stat] != 0:
			description += str(stat) + ": " + str(stats[stat]) + "\n"
