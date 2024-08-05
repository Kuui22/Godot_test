extends Control


func _on_fullscreen_pressed():
	#ProjectSettings.set_setting("display/window/size/resizable", false)
	if(!DisplayServer.window_get_mode()):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://menus/mainmenu.tscn")
