extends Node

var inv_data = {}

var equipment_data = {"MainHand": 10004,
		"Head": null,
		"Torso": null,
		"Legs": null,
		"Feet": null,
		"OffHand": null,
		"Back": null,
		"Neck": null,
		"Hands": null, 
		"Ammo": null}

func _ready():
	var inv_data_file = File.new()
	inv_data_file.open("res://Data/inv_data_file.json", File.READ)
	var inv_data_json = JSON.parse(inv_data_file.get_as_text())
	inv_data_file.close()
	inv_data = inv_data_json.result

func ChangeEquipment(equipment_slot, item_id):
	if ImportData.visible_equipment.has(equipment_slot):
		var player_node = get_node("/root/MainScene/Player")
		player_node.on_equipment_changed(equipment_slot, item_id)
	equipment_data[equipment_slot] = item_id
