extends CanvasLayer

onready var shortcuts_path = "SkillBar/Background/HBoxContainer/"
onready var main_hand_icon = get_node("/root/MainScene/CanvasLayer/CharacterSheet/VBoxContainer/HBoxContainer/VBoxContainer/Equipment/HBoxContainer/LeftSlots/MainHand/Icon")

var loaded_skills = {
	"ShortCut1" : {"Name": "10007", "Type": "Skill"},
	"ShortCut2" : {"Name": null, "Type": null},
	"ShortCut3" : {"Name": null, "Type": null},
	"ShortCut4" : {"Name": null, "Type": null},
	"ShortCut5" : {"Name": null, "Type": null},
	"ShortCut6" : {"Name": null, "Type": null},
	"ShortCut7" : {"Name": null, "Type": null}
}

func _ready():
	LoadShortCuts()
	for shortcut in get_tree().get_nodes_in_group("Shortcuts"):
		shortcut.connect("pressed", self, "SelectShortcut", [shortcut.get_parent().get_name()])
		
func LoadShortCuts():
	for shortcut in loaded_skills.keys():
		if loaded_skills[shortcut]["Name"] != null:
			if loaded_skills[shortcut]["Type"] == "Skill":
				var skill_icon = null
				if loaded_skills[shortcut]["Name"] == '10007':
					if PlayerData.equipment_data["MainHand"]["Item"] == null:
						skill_icon = load("res://UI_elements/skill_icons/" + ImportData.skill_data[loaded_skills[shortcut]["Name"]]["SkillName"] + ".png")
					else:
						skill_icon = main_hand_icon.texture
				else:
					skill_icon = load("res://UI_elements/skill_icons/" + ImportData.skill_data[loaded_skills[shortcut]["Name"]]["SkillName"] + ".png")
				get_node(shortcuts_path + shortcut + "/TextureButton").set_normal_texture(skill_icon)
				get_node(shortcuts_path + shortcut + "/TextureButton/Sweep").texture_progress = skill_icon
				get_node(shortcuts_path + shortcut + "/TextureButton/Sweep/Timer").wait_time = ImportData.skill_data[loaded_skills[shortcut]["Name"]]["SkillCoolDown"]
				get_node(shortcuts_path + shortcut + "/TextureButton/Counter/Amount").hide()
				
			if loaded_skills[shortcut]["Type"] == "Item":
				var item_icon = null
				var amount = 0
				var item_name = ImportData.item_data[loaded_skills[shortcut]["Name"]]["Name"]
				for item_slot in PlayerData.inv_data:
					if loaded_skills[shortcut]["Name"] == str(PlayerData.inv_data[item_slot]["Item"]):
						amount += PlayerData.inv_data[item_slot]["Stack"]
				item_icon = load("res://Sprites/Icon_Items/" + ImportData.item_data[loaded_skills[shortcut]["Name"]]["Name"] + ".png")
				get_node(shortcuts_path + shortcut + "/TextureButton/Sweep").texture_progress = item_icon
				get_node(shortcuts_path + shortcut + "/TextureButton").set_normal_texture(item_icon)
				if amount <= 0:
					pass
				get_node(shortcuts_path + shortcut + "/TextureButton/Sweep/Timer").wait_time = 20
				get_node(shortcuts_path + shortcut + "/TextureButton/Counter/Amount").text = str(amount)
				get_node(shortcuts_path + shortcut + "/TextureButton/Counter/Amount").show()
		else:
			get_node(shortcuts_path + shortcut + "/TextureButton").set_normal_texture(null)
			get_node(shortcuts_path + shortcut + "/TextureButton/Sweep").texture_progress = null
			get_node(shortcuts_path + shortcut + "/TextureButton/Sweep/Timer").wait_time = 0
			get_node(shortcuts_path + shortcut + "/TextureButton/Counter/Amount").hide()

func SelectShortcut(shortcut):
	if loaded_skills[shortcut]["Type"] == "Skill":
		var player = get_parent().get_node("Player")
		player.player_selected_skill = loaded_skills[shortcut]["Name"]
		player.selected_skill_texture_button_node = get_node(shortcuts_path + shortcut + "/TextureButton")
		if ImportData.skill_data[player.player_selected_skill].SkillType == "Buff" and player.buffed == true:
			return
		if player.selected_skill_texture_button_node.get_node("Sweep/Timer").time_left == 0 && player.mana >= ImportData.skill_data[player.player_selected_skill].SkillMana:
			if ImportData.skill_data[loaded_skills[shortcut]["Name"]].QuickCast:
				player.SkillLoop(player.selected_skill_texture_button_node)
			else:
				get_node("MouseCursorSkill").set_as_cursor()
				player.hasSkillCursor = true
				var skill_range = ImportData.skill_data[loaded_skills[shortcut]["Name"]].SkillRange
				player.showSkillRange(skill_range)
	if loaded_skills[shortcut]["Type"] == "Item":
		var inventory_slot = null
		for item_slot in PlayerData.inv_data:
			if loaded_skills[shortcut]["Name"] == str(PlayerData.inv_data[item_slot]["Item"]):
				var node = get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer/" + item_slot + "/Icon").use_click(get_viewport().get_mouse_position())


