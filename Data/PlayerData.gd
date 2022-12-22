extends Node

onready var player = get_node("/root/MainScene/Player")
onready var character_sheet = get_node("/root/MainScene/CanvasLayer/CharacterSheet")

var inv_data = {}

var skills_data = {
	"Skill1": {
	"Name": "seventh"
  },
  "Skill2": {
	"Name": "first",
  }}

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
			
var equipment_stats = {"Strength": 0,
			"Stamina": 0,
			"Intelligence": 0,
			"Dexterity": 0,
			"Level": 0,
			"PhysicalAttack": 0,
			"MagicalAttack": 0,
			"BlockChance": 0,
			"Defense": 0,
			"CriticalFactor": 0,
			"CriticalChance": 0,
			"MaxHealth": 0,
			"HealthRegeneration": 0,
			"MaxMana": 0,
			"ManaRegeneration": 0,
			"DodgeChance": 0,
			"MovementSpeed": 0,
			"AttackSpeed": 0}

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
	var old_item_id = equipment_data[equipment_slot]
	equipment_data[equipment_slot] = item_id
	AddEquipmentStats(old_item_id, item_id)
	
func AddEquipmentStats(old_item_id, new_item_id):
	if old_item_id != null:
		for i in range(ImportData.item_stats.size()):
			var stat_name = ImportData.item_stats[i]
			var stat_value = ImportData.item_data[str(old_item_id)][stat_name]
			if stat_value != null:
				equipment_stats[stat_name] -= stat_value
	
	if new_item_id != null:
		for i in range(ImportData.item_stats.size()):
			var stat_name = ImportData.item_stats[i]
			var stat_value = ImportData.item_data[str(new_item_id)][stat_name]
			if stat_value != null:
				print(stat_name, stat_value)
				equipment_stats[stat_name] += stat_value
	LoadStats()
	if is_instance_valid(player):
		player.update_healthbars()
	if is_instance_valid(character_sheet):
		character_sheet.LoadStats()
	
	

func LoadStats():
	player_stats["PhysicalAttack"] = int(30 + float(player_stats["Strength"] + player_stats["Level"])/3 + float(equipment_stats["PhysicalAttack"]))
	player_stats["MagicalAttack"] = int(75 + float(player_stats["Intelligence"] + player_stats["Level"])/2 + float(equipment_stats["MagicalAttack"]))
	player_stats["BlockChance"] = 0.1 + float(player_stats["Stamina"] + player_stats["Level"])/100  + float(equipment_stats["BlockChance"])
	player_stats["Defense"] = 50 + int(float(player_stats["Stamina"] + player_stats["Level"])/2 + + float(equipment_stats["Defense"]))
	player_stats["CriticalFactor"] = 1.5 + float(player_stats["Dexterity"] + player_stats["Level"])/50 + float(equipment_stats["CriticalFactor"])
	player_stats["CriticalChance"] = 0.1 + float(player_stats["Dexterity"] + player_stats["Level"])/100 + float(equipment_stats["CriticalChance"])
	player_stats["MaxHealth"] = 100 + player_stats["Stamina"] + player_stats["Level"] + int(equipment_stats["MaxHealth"])
	player_stats["HealthRegeneration"] = 1 + float(player_stats["Stamina"] + player_stats["Level"])/100 + float(equipment_stats["HealthRegeneration"])
	player_stats["MaxMana"] = 100 + float(player_stats["Intelligence"] + player_stats["Level"])  + int(equipment_stats["MaxMana"])
	player_stats["ManaRegeneration"] = 1 + float(player_stats["Intelligence"] + player_stats["Level"])/100 + float(equipment_stats["ManaRegeneration"])
	player_stats["DodgeChance"] = 0.05 + float(player_stats["Dexterity"] + player_stats["Level"])/1000 + float(equipment_stats["DodgeChance"])
	player_stats["MovementSpeed"] = 120 + float(player_stats["Dexterity"] + player_stats["Level"])*1 + float(equipment_stats["MovementSpeed"])
	player_stats["AttackSpeed"] = 0.5 + float(player_stats["Dexterity"] + player_stats["Level"])/25 + float(equipment_stats["AttackSpeed"])
	if is_instance_valid(player):
		player.update_healthbars()
