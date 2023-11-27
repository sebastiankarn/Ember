extends Node

var skill_tree_data
var skill_data
var item_data = {}
var npc_data = {}
var item_stats = ["PhysicalAttack",
				 "MagicalAttack",
				 "Defense",
				 "BlockChance",
				 "PotionHealth",
				 "PotionMana",
				 "FoodSatiation",
				 "Strength",
				 "Stamina",
				 "Intelligence",
				 "Dexterity",
				 "CriticalFactor",
				 "CriticalChance",
				 "MaxHealth",
				 "HealthRegeneration",
				 "MaxMana",
				 "ManaRegeneration",
				 "DodgeChance",
				 "MovementSpeed",
				 "AttackSpeed"
				]

var item_stat_labels = ["Physical Attack", 
						"Magical Attack", 
						"Defense", 
						"Block Chance", 
						"Health", 
						"Mana", 
						"Satiation",
						"Strength",
						"Stamina",
						"Intelligence",
						"Dexterity",
						"Critical Factor",
						"Critical Chance",
						"Health",
						"Health Regeneration",
						"Mana",
						"Mana Regeneration",
						"Dodge Chance",
						"Movement Speed",
						"Attack Speed"]
var visible_equipment = ["MainHand", "Feet", "Legs", "Torso", "Head", "OffHand"]
var naked_gear = {"MainHand": null, "Feet": null, "Legs": null, "Torso": null, "Head": null, "OffHand": null}

var item_rarity_distribution = {
	"Common": 60,
	"Uncommon": 27,
	"Rare": 9,
	"Epic": 3,
	"Legendary": 1
	}
	
var item_scaling_stats = [
	"PhysicalAttack",
	"MagicalAttack",
	"Defense",
	"Strength",
	"Stamina",
	"Intelligence",
	"Dexterity",
	"MaxHealth",
	"MaxMana"
	]

var magical_properties_data = {}

var item_magical_chance = {
	"Common": 10,
	"Uncommon": 25,
	"Rare": 45,
	"Epic": 65,
	"Legendary": 90
}
var item_magical_prefixes = ["Fierce", "Sharp", "Blocking", "Stout", "Vigorous", "Swift"]
var item_magical_suffixes = ["of the Flame", "of the Storm", "of the Agile", "of the Warrior", "of the Defender"]

var skill_stats = [
				"SkillLevel",
				"SkillDamage",
				"SkillHeal",
				"SkillRange",
				"SkillMana",
				"SkillCoolDown"
				]

var skill_stat_labels = [
						"Required level",
						"Damage", 
						"Heal amount", 
						"Range", 
						"Mana cost", 
						"Cooldown"
						]

func _ready():
	skill_data = load_json_data("res://Data/SkillData.json")
	item_data = load_json_data("res://Data/ItemData.json")
	npc_data = load_json_data("res://Data/npc_data_file.json")
	magical_properties_data = load_json_data("res://Data/MagicalPropertiesData.json")
	skill_tree_data = load_json_data("res://Data/SkillTreeData.json")

func load_json_data(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var file_text = file.get_as_text()
		file.close()

		var json_parser = JSON.new()
		var parse_result = json_parser.parse(file_text)
		if parse_result.error == OK:
			return parse_result.result
		else:
			printerr("JSON parsing error: ", parse_result.error_string)
	else:
		printerr("Failed to open file: ", file_path)

	return {}  # Return an empty dictionary if there's an error
