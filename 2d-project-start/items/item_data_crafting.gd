extends ItemData

class_name ItemDataCrafting

@export var item_type:Type

enum Type {
	Randomizer,
	Enhancer,
	NOT
}

func use(_target):
	match item_type:
		0:
			PlayerManager.open_menu("RANDOMIZER")
		1:
			pass
		2:
			pass
