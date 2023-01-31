extends Node

var skill_tree_data
var skill_data
var item_data = {}
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
var visible_equipment = ["MainHand"]
var naked_gear = {"MainHand": null}

var item_rarity_distribution = {
	"Common": 60,
	"Uncommon": 27,
	"Rare": 9,
	"Epic": 3,
	"Legendary": 1
	}
	
var item_scaling_stats = ["PhysicalAttack", "MagicalAttack", "Defense"]

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

func _ready():
	var skill_data_file = File.new()
	skill_data_file.open("res://Data/SkillData.json", File.READ)
	var skill_data_json = JSON.parse(skill_data_file.get_as_text())
	skill_data_file.close()
	skill_data = skill_data_json.result
	
	var item_data_file = File.new()
	item_data_file.open("res://Data/ItemData.json", File.READ)
	var item_data_json = JSON.parse(item_data_file.get_as_text())
	item_data_file.close()
	item_data = item_data_json.result
	
	var magical_properties_data_file = File.new()
	magical_properties_data_file.open("res://Data/MagicalPropertiesData.json", File.READ)
	var magical_properties_data_json = JSON.parse(magical_properties_data_file.get_as_text())
	magical_properties_data_file.close()
	magical_properties_data = magical_properties_data_json.result
	
	var skill_tree_data_file = File.new()
	skill_tree_data_file.open("res://Data/SkillTreeData.json", File.READ)
	var skill_tree_data_json = JSON.parse(skill_tree_data_file.get_as_text())
	skill_tree_data_file.close()
	skill_tree_data = skill_tree_data_json.result
