extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_resume_button_pressed():
	Engine.time_scale = 1
	get_parent().visible = false


func _on_exit_button_pressed():
	get_parent().get_parent().get_tree().quit()
