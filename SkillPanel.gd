extends Control

var template_skill_slot = preload("res://Templates/SkillPanelSlot.tscn")

onready var container = get_node("Background/M/V/ScrollContainer/V")

func _ready():
	for i in PlayerData.skills_data.keys():
		var skill_slot_new = template_skill_slot.instance()
		if PlayerData.skills_data[i]["Name"] != null:
			var skill_name = PlayerData.skills_data[i]["Name"]
			var icon_texture = load("res://UI_elements/skill_icons/" + skill_name + ".png")
			skill_slot_new.get_node("Icon").set_texture(icon_texture)
			var skill_text = ImportData.skill_data[PlayerData.skills_data[i]["Name"]]["SkillType"]
			if skill_text != null:
				skill_slot_new.get_node("Stack").set_text(skill_text)
		container.add_child(skill_slot_new, true)


func _on_Button_pressed():
	self.hide()
