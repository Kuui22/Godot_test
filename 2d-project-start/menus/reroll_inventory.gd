extends Control

@onready var item_texture: TextureRect = $Control/ItemTexture


var equiplist:Array[SlotData]

func _on_left_button_pressed() -> void:
	pass # Replace with function body.


func _on_right_button_pressed() -> void:
	pass # Replace with function body.


func update_equiplist(equiparray):
	equiplist = equiparray
	print(equiplist)
