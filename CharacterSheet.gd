extends Control

onready var player = get_node("../../Player")
onready var node_stat_points = get_node("VBoxContainer/HBoxContainer/VBoxContainer/Stats/MainStats/HBoxContainer/Label")
onready var node_skill_points = get_node("VBoxContainer/HBoxContainer/VBoxContainer/Skills/SkillTree/1/SkillPoints")
var path_main_stats = "VBoxContainer/HBoxContainer/VBoxContainer/Stats/MainStats/"

var available_points
var strength_add = 0
var constitution_add = 0
var dexterity_add = 0
var intelligence_add = 0
var wisdom_add = 0

func _ready():
	LoadStats()
	LoadSkills()
	available_points = player.stat_points
	node_stat_points.set_text(str(available_points) + " Points")
	node_skill_points.set_text(str(player.skill_points) + "\n Points")
	if available_points == 0:
		pass
	else:
		for button in get_tree().get_nodes_in_group("PlusButtons"):
			button.set_disabled(false)
			
	for button in get_tree().get_nodes_in_group("PlusButtons"):
		button.connect("pressed", self, "IncreaseStat", [button.get_node("../..").get_name()])
	for button in get_tree().get_nodes_in_group("MinButtons"):
		button.connect("pressed", self, "DecreaseStat", [button.get_node("../..").get_name()])
	for button in get_tree().get_nodes_in_group("SkillButtons"):
		button.connect("pressed", self, "SpendSkillPoint", [button.get_parent().get_name()])
		
func LoadStats():
	get_node(path_main_stats + "Strength/StatBackground/Stats/Value").set_text("+" + str(player.strength))
	get_node(path_main_stats + "Constitution/StatBackground/Stats/Value").set_text("+" + str(player.constitution))
	get_node(path_main_stats + "Dexterity/StatBackground/Stats/Value").set_text("+" + str(player.dexterity))
	get_node(path_main_stats + "Intelligence/StatBackground/Stats/Value").set_text("+" + str(player.intelligence))
	get_node(path_main_stats + "Wisdom/StatBackground/Stats/Value").set_text("+" + str(player.wisdom))

func LoadSkills():
	for skill in get_tree().get_nodes_in_group("Skills"):
		if player.get("skill_" + skill.get_name()) == true:
			get_node("VBoxContainer/HBoxContainer/VBoxContainer/Skills/SkillTree/" 
			+ skill.get_name().left(1) + "/" + skill.get_name() + "/TextureButton").set_disabled(false)
		elif player.get("skill_" + ImportData.skill_tree_data[skill.get_name()].UnlockSkill) == true:
			if player.curLevel >= ImportData.skill_tree_data[skill.get_name()].ReqPlayerLevel:
				var texture_button = get_node("VBoxContainer/HBoxContainer/VBoxContainer/Skills/SkillTree/" 
				+ skill.get_name().left(1) + "/" + skill.get_name() + "/TextureButton")
				texture_button.set_disabled(false)
				texture_button.set_modulate(Color(0.4, 0.4, 0.4, 1))
			
		
	#for skill in get_tree().get_nodes_in_group("SkillConnectors"):
	#	pass

func IncreaseStat(stat):
	set(stat.to_lower() + "_add", get(stat.to_lower() + "_add") + 1)
	get_node(path_main_stats + stat + "/StatBackground/Stats/Change").set_text("+" + str(get(stat.to_lower() + "_add")) + " ")	
	get_node(path_main_stats + stat + "/StatBackground/Min").set_disabled(false)
	
	available_points -= 1
	node_stat_points.set_text(str(available_points) + " Points")
	
	if available_points == 0:
		for button in get_tree().get_nodes_in_group("PlusButtons"):
			button.set_disabled(true)
			
			
func DecreaseStat(stat):
	set(stat.to_lower() + "_add", get(stat.to_lower() + "_add") - 1)
	if get(stat.to_lower() + "_add") == 0:
		get_node(path_main_stats + stat + "/StatBackground/Min").set_disabled(true)
		get_node(path_main_stats + stat + "/StatBackground/Stats/Change").set_text("")	
	else:
		get_node(path_main_stats + stat + "/StatBackground/Stats/Change").set_text("+" + str(get(stat.to_lower() + "_add")) + " ")
		
	available_points += 1
	node_stat_points.set_text(str(available_points) + " Points")
	for button in get_tree().get_nodes_in_group("PlusButtons"):
		button.set_disabled(false)

func SpendSkillPoint(skill):
	if player.get("skill_" + skill) == true:
		pass
	else:
		if player.skill_points < ImportData.skill_tree_data[skill].Cost:
			pass
		else:
			var unlock_skill = ImportData.skill_tree_data[skill].UnlockSkill
			var tween = get_node("VBoxContainer/HBoxContainer/VBoxContainer/Skills/SkillTree/" + 
			skill.left(1) + "/" + skill + "/TextureRect/Tween")
			tween.interpolate_property(tween.get_parent(), 'rect_scale', Vector2(1, 1), Vector2(2.2, 2.2), 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
			tween.interpolate_property(tween.get_parent(), 'rect_scale', Vector2(2.2, 2.2), Vector2(1, 1), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)
			tween.start()
			yield(get_tree().create_timer(0.6), "timeout")
			var texture_button = get_node("VBoxContainer/HBoxContainer/VBoxContainer/Skills/SkillTree/" + 
			skill.left(1) + "/" + skill + "/TextureButton")
			texture_button.set_modulate(Color(1, 1, 1, 1))
			
			player.set("skill_" + skill, true)
			
			player.skill_points -= ImportData.skill_tree_data[skill].Cost
			node_skill_points.set_text(str(player.skill_points) + "\n Points")
			
			var unlocked_skills = []
			for key in ImportData.skill_tree_data.keys():
				if ImportData.skill_tree_data[key].UnlockSkill == skill:
					if player.curLevel >= ImportData.skill_tree_data[key].ReqPlayerLevel:
						unlocked_skills.append(key)
						
			if not unlocked_skills == []:
				for key in unlocked_skills:
					texture_button = get_node("VBoxContainer/HBoxContainer/VBoxContainer/Skills/SkillTree/" + 
					key.left(1) + "/" + key + "/TextureButton")
					texture_button.set_disabled(false)
					texture_button.set_modulate(Color(0.4, 0.4, 0.4, 1))
					
			
			

func _on_Confirm_pressed():
	if strength_add + dexterity_add + constitution_add + intelligence_add + wisdom_add == 0:
		print("Nothing to add")
	else:
		player.stat_points = available_points
		player.strength += strength_add
		player.constitution += constitution_add
		player.dexterity += dexterity_add
		player.intelligence += intelligence_add
		player.wisdom += wisdom_add
		strength_add = 0
		constitution_add = 0
		dexterity_add = 0
		intelligence_add = 0
		wisdom_add = 0
		LoadStats()
		for button in get_tree().get_nodes_in_group("MinButtons"):
			button.set_disabled(true)
		for label in get_tree().get_nodes_in_group("ChangeLabels"):
			label.set_text("")


func _on_Stats_pressed():
	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Skills").hide()
	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Stats").show()
	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Equipment").hide()

func _on_Skills_pressed():
	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Skills").show()
	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Stats").hide()
	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Equipment").hide()
	


func _on_Equipment_pressed():
	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Skills").hide()
	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Stats").hide()
	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Equipment").show()


func _on_Button_pressed():
	self.hide()
