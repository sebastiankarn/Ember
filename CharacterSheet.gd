extends Control

onready var player = get_node("../../Player")
onready var node_stat_points = get_node("HBoxContainer/VBoxContainer/Stats/MainStats/HBoxContainer/Label")
var path_main_stats = "HBoxContainer/VBoxContainer/Stats/MainStats/"

var available_points
var strength_add = 0
var constitution_add = 0
var dexterity_add = 0
var intelligence_add = 0
var wisdom_add = 0

func _ready():
	LoadStats()
	available_points = player.stat_points
	node_stat_points.set_text(str(available_points) + " Points")
	if available_points == 0:
		pass
	else:
		for button in get_tree().get_nodes_in_group("PlusButtons"):
			button.set_disabled(false)
			
	for button in get_tree().get_nodes_in_group("PlusButtons"):
		button.connect("pressed", self, "IncreaseStat", [button.get_node("../..").get_name()])
	for button in get_tree().get_nodes_in_group("MinButtons"):
		button.connect("pressed", self, "DecreaseStat", [button.get_node("../..").get_name()])

func LoadStats():
	get_node(path_main_stats + "Strength/StatBackground/Stats/Value").set_text("+" + str(player.strength))
	get_node(path_main_stats + "Constitution/StatBackground/Stats/Value").set_text("+" + str(player.constitution))
	get_node(path_main_stats + "Dexterity/StatBackground/Stats/Value").set_text("+" + str(player.dexterity))
	get_node(path_main_stats + "Intelligence/StatBackground/Stats/Value").set_text("+" + str(player.intelligence))
	get_node(path_main_stats + "Wisdom/StatBackground/Stats/Value").set_text("+" + str(player.wisdom))

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
