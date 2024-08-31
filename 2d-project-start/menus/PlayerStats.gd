extends PanelContainer

#this here populates the stats onready in main.gd and then when stats are changed, a signal from playermanager will
#activate the updating function

const statlabel = preload("res://menus/stat.tscn")

@onready var player_stats = $"."
@onready var margin_container = $MarginContainer
@onready var grid_container = $MarginContainer/GridContainer




func populate_stats_ui(playerstat:Dictionary)-> void:
	var keys = playerstat.keys()
	for key in keys:
		var value = playerstat[key]
		print(key + ": " + str(value))  # Prints each key-value pair
		var stat = statlabel.instantiate()
		stat.text = key + " : " + str(value)
		grid_container.add_child(stat)
		#print(margin_container.get_child_count())
	
func update_stats_ui(playerstat:Dictionary) -> void:
	var keys = playerstat.keys()
	var x:int = 0
	for key in keys:
		var value = playerstat[key]
		var currchild = grid_container.get_child(x)
		currchild.text = key + " : " + str(value)
		x +=1
