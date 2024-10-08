extends Control
@onready var main_hand_icon = get_node("/root/MainScene/CanvasLayer/CharacterSheet/VBoxContainer/HBoxContainer/VBoxContainer/Equipment/HBoxContainer/LeftSlots/MainHand/Icon")
var template_skill_slot = preload("res://Templates/SkillPanelSlot.tscn")

@onready var container = get_node("Background/M/V/ScrollContainer/V")

func _ready():
	reload_skills()

func reload_skills():
	for i in container.get_child_count():
		container.remove_child(container.get_child(0))
	var counter = 1
	for i in PlayerData.skills_data.keys():
		var skill_slot = "Skill" + str(counter)
		if PlayerData.skills_data[skill_slot]["Id"] != null:
			var skill_slot_new = template_skill_slot.instantiate()
			var skill_name = ImportData.skill_data[PlayerData.skills_data[skill_slot]["Id"]].SkillName
			var icon_texture = load("res://UI_elements/skill_icons/" + skill_name + ".png")
			if skill_name == "Auto Attack" and PlayerData.equipment_data["MainHand"]["Item"] != null:
				icon_texture = main_hand_icon.texture
			skill_slot_new.get_node("TextureRect/IconBackground/Icon").set_texture(icon_texture)
			var skill_text = ImportData.skill_data[PlayerData.skills_data[skill_slot]["Id"]]["SkillInfo"]
			if skill_text != null:
				skill_slot_new.get_node("TextureRect/Stack").set_text(skill_text)
			skill_slot_new.name = skill_slot
			container.add_child(skill_slot_new, true)
		counter = counter + 1

func _on_Button_pressed():
	self.hide()
