extends CanvasLayer

onready var shortcuts_path = "SkillBar/Background/HBoxContainer/"

var loaded_skills = {"ShortCut1" : "first", "ShortCut2" : "second", "ShortCut3" : "third",
"ShortCut4" : "fourth", "ShortCut5" : "fifth"}

func _ready():
	LoadShortCuts()
	for shortcut in get_tree().get_nodes_in_group("Shortcuts"):
		shortcut.connect("pressed", self, "SelectShortcut", [shortcut.get_parent().get_name()])
		
func LoadShortCuts():
	for shortcut in loaded_skills.keys():
		var skill_icon = load("res://UI_elements/skill_icons/" + loaded_skills[shortcut] + ".png")
		get_node(shortcuts_path + shortcut + "/TextureButton").set_normal_texture(skill_icon)
	
func SelectShortcut(shortcut):
	get_parent().get_node("Player").selected_skill = loaded_skills[shortcut]
