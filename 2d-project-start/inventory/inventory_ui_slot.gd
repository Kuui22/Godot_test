extends Panel

@onready var item_visual:Sprite2D = $CenterContainer/Panel/ItemDisplay

func update(item:inv_item):
	if(item):
		item_visual.visible = true
		item_visual.texture = item.texture
	else:
		item_visual.visible = false
