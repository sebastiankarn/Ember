extends Node

var skill_tree_data

func _ready():
	var skill_tree_data_file = File.new()
	skill_tree_data_file.open("res://Data/SkillTreeData.json", File.READ)
	var skill_tree_data_json = JSON.parse(skill_tree_data_file.get_as_text())
	skill_tree_data_file.close()
	skill_tree_data = skill_tree_data_json.result
	
