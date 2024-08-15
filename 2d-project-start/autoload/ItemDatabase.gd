extends Node

var example_dict = {}
const loot_table_path = "res://mobs/loottables/"

func _ready():
	import_resources_data()
	#print(get_item())

func import_resources_data():
	var file = FileAccess.open("res://autoload/Itemdb.csv", FileAccess.READ)
	while !file.eof_reached():
		var data_set = Array(file.get_csv_line())
		example_dict[example_dict.size()] = data_set

	file.close()

	#print(example_dict)

func get_item(ID = 1):
	#0 is id 1 is name 2 is category 3 is filename
	var category = example_dict[ID][2]
	var filename = example_dict[ID][3]
	var item = load("res://items/"+category+"/"+filename) 
	
	return item


func get_loot_table(mobname:String):
	var tablepath:String = loot_table_path + mobname + ".csv"
	var file = FileAccess.open(tablepath, FileAccess.READ)
	var loot_table = {}
	while !file.eof_reached():
		var data_set = Array(file.get_csv_line())
		loot_table[loot_table.size()] = data_set

	file.close()
	return loot_table
