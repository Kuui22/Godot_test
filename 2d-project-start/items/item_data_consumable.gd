extends ItemData

class_name ItemDataConsumable

@export var item_type:Type

enum Type {
	Healing,
	StatBooster,
	NOT
}
func use(_target) -> void:
	match item_type:
		0:
			print("Healing")
		1:
			print("StatBooster")
		2:
			pass
