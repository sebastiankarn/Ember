extends Node

onready var player = get_node("/root/MainScene/Player")

var inv_data = {}

var equipment_data = {"MainHand": null,
		"Head": null,
		"Torso": null,
		"Legs": null,
		"Feet": null,
		"OffHand": null,
		"Back": null,
		"Neck": null,
		"Hands": null, 
		"Ammo": null}

var player_stats = {"Strength": 1,
			"Stamina": 2,
			"Intelligence": 4,
			"Dexterity": 3,
			"Level": 1,
			"PhysicalAttack": 10,
			"MagicalAttack": 10,
			"BlockChance": 10,
			"Defense": 10,
			"CriticalFactor": 1.5,
			"CriticalChance": 0.1,
			"MaxHealth": 100,
			"HealthRegeneration": 1,
			"MaxMana": 100,
			"ManaRegeneration": 1,
			"DodgeChance": 0.1,
			"MovementSpeed": 140,
			"AttackSpeed": 1}

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

func LoadStats():
	player_stats["PhysicalAttack"] = int(1 + float(player_stats["Strength"] + player_stats["Level"])/3)
	player_stats["MagicalAttack"] = int(75 + float(player_stats["Intelligence"] + player_stats["Level"])/2)
	player_stats["BlockChance"] = 0.1 + float(player_stats["Stamina"] + player_stats["Level"])/100
	player_stats["Defense"] = 50 + float(player_stats["Stamina"] + player_stats["Level"])/2
	player_stats["CriticalFactor"] = 1.5 + float(player_stats["Dexterity"] + player_stats["Level"])/50
	player_stats["CriticalChance"] = 0.1 + float(player_stats["Dexterity"] + player_stats["Level"])/100
	player_stats["MaxHealth"] = 100 + player_stats["Stamina"] + player_stats["Level"] 
	player_stats["HealthRegeneration"] = 1 + float(player_stats["Stamina"] + player_stats["Level"])/100
	player_stats["MaxMana"] = 100 + float(player_stats["Intelligence"] + player_stats["Level"])
	player_stats["ManaRegeneration"] = 1 + float(player_stats["Intelligence"] + player_stats["Level"])/100 
	player_stats["DodgeChance"] = float(player_stats["Dexterity"] + player_stats["Level"])/1000
	player_stats["MovementSpeed"] = 140 + float(player_stats["Dexterity"] + player_stats["Level"])*1
	player_stats["AttackSpeed"] = 1 + float(player_stats["Dexterity"] + player_stats["Level"])*0
	player.update_healthbars()
