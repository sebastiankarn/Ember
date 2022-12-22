extends CanvasLayer

onready var shortcuts_path = "SkillBar/Background/HBoxContainer/"
onready var main_hand_icon = get_node("/root/MainScene/CanvasLayer/CharacterSheet/VBoxContainer/HBoxContainer/VBoxContainer/Equipment/HBoxContainer/LeftSlots/MainHand/Icon")

var loaded_skills = {"ShortCut1" : "seventh", "ShortCut2" : "first", "ShortCut3" : "fifth",
"ShortCut4" : "sixth", "ShortCut5" : "fourth", "ShortCut6": "third", "ShortCut7": "second"}

func _ready():
	LoadShortCuts()
	for shortcut in get_tree().get_nodes_in_group("Shortcuts"):
		shortcut.connect("pressed", self, "SelectShortcut", [shortcut.get_parent().get_name()])
		
func LoadShortCuts():
	var i = 0
	for shortcut in loaded_skills.keys():
		if  PlayerData.player_stats["Level"] < i:
			return
		i += 1
		var skill_icon = null
		if loaded_skills[shortcut] == 'seventh':
			print(PlayerData.equipment_data["MainHand"])
			if PlayerData.equipment_data["MainHand"] == null:
				skill_icon = load("res://UI_elements/skill_icons/fist.png")
			else:
				skill_icon = main_hand_icon.texture
		else:
			skill_icon = load("res://UI_elements/skill_icons/" + loaded_skills[shortcut] + ".png")
		get_node(shortcuts_path + shortcut + "/TextureButton").set_normal_texture(skill_icon)
	
func SelectShortcut(shortcut):
	get_parent().get_node("Player").selected_skill = loaded_skills[shortcut]
