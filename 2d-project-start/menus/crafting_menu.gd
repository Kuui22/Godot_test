extends Control

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
@onready var tab_container: TabContainer = $TabContainer



func _on_exit_button_pressed() -> void:
	self.visible = false


func _on_tab_container_gui_input(event: InputEvent) -> void:
	pass
	'''
	print("here")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				dragging = true
				drag_offset = event.position - position
				# Grab the focus to ensure we capture the mouse motion events
				grab_focus()
			else:
				# Stop dragging
				dragging = false
				release_focus()

	elif event is InputEventMouseMotion and dragging:
		position = event.position - drag_offset
	'''


func _on_tab_container_tab_hovered(tab: int) -> void:
	print("here")
