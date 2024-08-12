extends Resource

class_name ItemData

#base variables for items
@export var name:String = ""
@export_multiline var description:String = ""
@export var stackable:bool = false
@export var texture: AtlasTexture 
@export var sell_value:int = 0

func use(_target) -> void:
	pass
	
