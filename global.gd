extends Node

var items

func _ready():
	items = read_from_JSON("res://json/items.json")
	for key in items.keys():
		items[key]["key"] = key

func read_from_JSON(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var file_content = file.get_as_text()
		file.close()

		var test_json_conv = JSON.new()
		var error = test_json_conv.parse(file_content)
		if error == OK:
			var data = test_json_conv.get_data()
			return data
		else:
			printerr("JSON parsing failed")
	else:
		printerr("Invalid path given or file not found")


func get_item_by_key(key):
	if items and items.has(key):
		return items[key].duplicate(true)
		

