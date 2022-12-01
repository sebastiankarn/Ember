extends Node

var skill_tree_data
var skill_data
var item_data = {}

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
	
	var skill_tree_data_file = File.new()
	skill_tree_data_file.open("res://Data/SkillTreeData.json", File.READ)
	var skill_tree_data_json = JSON.parse(skill_tree_data_file.get_as_text())
	skill_tree_data_file.close()
	skill_tree_data = skill_tree_data_json.result
	
