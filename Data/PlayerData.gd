extends Node

var inv_data = {}

var quest_data = {
	"10001": {
		"Accepted": false,
		"Completed": false,
		"Abandoned": false
	},
	"10002": {
		"Accepted": false,
		"Completed": false,
		"Abandoned": false
	},
	"10003": {
		"Accepted": false,
		"Completed": false,
		"Abandoned": false
	},
	"10004": {
		"Accepted": false,
		"Completed": false,
		"Abandoned": false
	},
	"10005": {
		"Accepted": false,
		"Completed": false,
		"Abandoned": false
	}
}

var quest_requirements_tracking = {
	"Kill": {
		"Wolf": {
			"10001": null
			},
		"Minotaur": {
			"10003": null
		},
		"Demon": {
			"10003": null
		},
		"Vampire": {
			"10004": null
		},
		"Vampire Lord": {
			"10004": null
		},
		"Possessed Elf": {
			"10005": null
		}
	},
	"Collect": {
		"Wolf Paw": {
			"10002": null
		},
		"Minotaur Horn": {
			"10003": null
		},
		"Eerie Artifact": {
			"10005": null
		},
		"Haunted Vile": {
			"10005": null
		}
	},
	"Talk": {
		"Hunter": {
			"10005": null
		}
	}
}

var skills_data = {
	"Skill1": {
	"Id": "10007"
	},
	"Skill2": {
	"Id": "10013"
	},
	"Skill3": {
	"Id": "10014"
	},
	"Skill4": {
	"Id": null
	},
	"Skill5": {
	"Id": null
	},
	"Skill6": {
	"Id": null
	},
	"Skill7": {
	"Id": null
	},
	"Skill8": {
	"Id": null
	},
	"Skill9": {
		"Id": null
	},
	"Skill10": {
		"Id": null
	},
	"Skill11": {
		"Id": null
	},
	"Skill12": {
		"Id": null
	},
	"Skill13": {
		"Id": null
	},
	"Skill14": {
		"Id": null
	},
	"Skill15": {
		"Id": null
	},
	"Skill16": {
		"Id": null
	}
}

var equipment_data = {"MainHand": {"Item": null, "Info": null, "Stats": null},
		"Head": {"Item": null, "Info": null, "Stats": null},
		"Torso": {"Item": null, "Info": null, "Stats": null},
		"Legs": {"Item": null, "Info": null, "Stats": null},
		"Feet": {"Item": null, "Info": null, "Stats": null},
		"OffHand": {"Item": null, "Info": null, "Stats": null},
		"Back": {"Item": null, "Info": null, "Stats": null},
		"Neck": {"Item": null, "Info": null, "Stats": null},
		"Hands": {"Item": null, "Info": null, "Stats": null},
		"Ammo": {"Item": null, "Info": null, "Stats": null}
		}

var player_stats = {"Strength": 0,
			"Stamina": 0,
			"Intelligence": 0,
			"Dexterity": 0,
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
	var inv_data_file := FileAccess.open("res://Data/inv_data_file.json", FileAccess.READ)
	if inv_data_file:
		var file_text = inv_data_file.get_as_text()
		inv_data_file.close()

		var test_json_conv := JSON.new()
		var parse_result = test_json_conv.parse(file_text)
		if parse_result == OK:
			inv_data = test_json_conv.get_data()
		else:
			printerr("JSON parsing error: ", parse_result)
			inv_data = {}  # or handle the error appropriately
	else:
		printerr("Failed to open file: res://Data/inv_data_file.json")
		inv_data = {}  # or handle the error appropriately

func ChangeEquipment(equipment_slot, item_id, stats, info):
	var player_node = get_node("/root/MainScene/Player")
	if ImportData.visible_equipment.has(equipment_slot):
		player_node.on_equipment_changed(equipment_slot, item_id)
	var old_item_stats = equipment_data[equipment_slot]["Stats"]
	equipment_data[equipment_slot]["Item"] = item_id
	equipment_data[equipment_slot]["Stats"] = stats
	equipment_data[equipment_slot]["Info"] = info
	AddEquipmentStats(old_item_stats, stats)
	if(equipment_slot == "MainHand" or equipment_slot == "OffHand"):
		AddEnchantGlow()
	player_node.get_node("PlayerSprite2D").update_animation_sprites()

	#player_node.get_node("AnimatedSprite2D").update_current_map(player_node.get_node("AnimatedSprite2D"))
	
func AddEquipmentStats(old_item_stats, new_item_stats):
	var player_node = get_node("/root/MainScene/Player")
	var character_sheet = get_node("/root/MainScene/CanvasLayer/CharacterSheet")
	if old_item_stats != null:
		for i in range(ImportData.item_stats.size()):
			var stat_name = ImportData.item_stats[i]
			var stat_value = old_item_stats[stat_name]
			if stat_value != null:
				equipment_stats[stat_name] -= stat_value
	
	if new_item_stats != null:
		for i in range(ImportData.item_stats.size()):
			var stat_name = ImportData.item_stats[i]
			var stat_value = new_item_stats[stat_name]
			if stat_value != null:
				equipment_stats[stat_name] += stat_value
	LoadStats()
	if is_instance_valid(player_node):
		player_node.update_healthbars()
	if is_instance_valid(character_sheet):
		character_sheet.LoadStats()
	
func AddEnchantGlow():
	var player_node = get_node("/root/MainScene/Player")
	if equipment_data["MainHand"]["Stats"] != null:
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] == 0:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(1,1,1))
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] == 1:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(1,2,1))
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] >= 2:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(1,2.5,1))
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] == 3:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(1,3,1))
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] == 4:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(1,1,3))
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] == 5:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(1,1,4))
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] == 6:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(1,1,5))
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] == 7:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(5,0.5,0.5))
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] == 8:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(10,0.3,0.3))
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] == 9:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(6,1,8))
		if equipment_data["MainHand"]["Stats"]["EnchantedLevel"] >= 10:
			player_node.get_node('OnMainHandSprite').set_modulate(Color(1,10,10))
	if equipment_data["OffHand"]["Stats"] != null:
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] == 0:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(1,1,1))
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] == 1:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(1,2,1))
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] >= 2:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(1,2.5,1))
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] == 3:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(1,3,1))
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] == 4:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(1,1,3))
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] == 5:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(1,1,4))
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] == 6:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(1,1,5))
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] == 7:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(5,0.5,0.5))
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] == 8:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(10,0.3,0.3))
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] == 9:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(6,1,8))
		if equipment_data["OffHand"]["Stats"]["EnchantedLevel"] >= 10:
			player_node.get_node('OnOffHandSprite').set_modulate(Color(1,10,10))

func LoadStats():
	var player_node = get_node("/root/MainScene/Player")
	player_stats["PhysicalAttack"] = int(3 + float(player_stats["Strength"] + float(player_stats["Level"])/3)*2 + float(equipment_stats["PhysicalAttack"]))
	player_stats["MagicalAttack"] = int(75 + float(player_stats["Intelligence"] + float(player_stats["Level"])/3)/2 + float(equipment_stats["MagicalAttack"]))
	player_stats["BlockChance"] = clamp(float(equipment_stats["BlockChance"]), 0, 0.7)
	player_stats["Defense"] = int(3 + float(player_stats["Stamina"] + float(player_stats["Level"])/3)*4 + float(equipment_stats["Defense"]))
	player_stats["CriticalFactor"] = 1.5 + float(player_stats["Strength"] + float(player_stats["Level"])/3)*0.03 + float(equipment_stats["CriticalFactor"])
	player_stats["CriticalChance"] = clamp(float(0.02 + float(player_stats["Dexterity"])*0.01 + float(equipment_stats["CriticalChance"])), 0, 0.8)
	player_stats["MaxHealth"] = int(100 + (player_stats["Stamina"] + float(player_stats["Level"])/3)*5 + int(equipment_stats["MaxHealth"]))
	player_stats["HealthRegeneration"] = 1 + float(player_stats["Stamina"] + player_stats["Level"])/100 + float(equipment_stats["HealthRegeneration"])
	player_stats["MaxMana"] = 100 + float(player_stats["Intelligence"] + player_stats["Level"])  + int(equipment_stats["MaxMana"])
	player_stats["ManaRegeneration"] = 1 + float(player_stats["Intelligence"] + player_stats["Level"])/100 + float(equipment_stats["ManaRegeneration"])
	player_stats["DodgeChance"] = clamp(float(player_stats["Dexterity"])*0.01 + float(equipment_stats["DodgeChance"]), 0, 0.7)
	player_stats["MovementSpeed"] = int(80 + float(player_stats["Dexterity"] + player_stats["Level"])*0.3 + float(equipment_stats["MovementSpeed"]))
	player_stats["AttackSpeed"] = 0.5 + float(player_stats["Dexterity"])*0.02 + float(equipment_stats["AttackSpeed"])
	if is_instance_valid(player_node):
		player_node.update_healthbars()
