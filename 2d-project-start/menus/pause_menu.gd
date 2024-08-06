extends Control

func _on_resume_button_pressed():
	Engine.time_scale = 1
	get_parent().visible = false


func _on_exit_button_pressed():
	get_parent().get_parent().get_tree().quit()
