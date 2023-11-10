extends Control
onready var quest_title_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/NinePatchRect/Title")
onready var quest_list_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect/ScrollContainer/HBoxContainer/VBoxContainer/QuestVBox")
onready var quest_description_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/RichTextLabel")
onready var requirements_vbox = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/RequirementsVBox")
onready var right_panel_content = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer")
onready var rewards_hbox = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/RewardsHBox")

var template_quest_reward = preload("res://Templates/QuestReward.tscn")
var template_quest_requirement = preload("res://Templates/QuestRequirement.tscn")
var template_quest = preload("res://Templates/Quest.tscn")

var selected_quest_id
var selected_quest_texture

func _ready():
	load_right_panel()
	load_left_panel()

func load_right_panel():
	if selected_quest_id != null:
		#Load panel
		right_panel_content.show()
		var quest_title = ImportData.quest_data[selected_quest_id]["Title"]
		var quest_description = ImportData.quest_data[selected_quest_id]["Description"]
		var quest_requirements = ImportData.quest_data[selected_quest_id]["CompletionRequirements"]
		var quest_rewards = ImportData.quest_data[selected_quest_id]["Rewards"]
		set_quest_title(quest_title)
		set_quest_description(quest_description)
		set_quest_requirements(quest_requirements)
		set_quest_rewards(quest_rewards)
	else:
		right_panel_content.hide()

func set_quest_title(title):
	quest_title_node.set_text(title)

func set_quest_description(description):
	quest_description_node.set_text(description)

func set_quest_requirements(requirements):
	for i in requirements_vbox.get_child_count():
		requirements_vbox.remove_child(requirements_vbox.get_child(0))

	for i in requirements.keys():
		var description = requirements[i]["Description"]
		var amount = requirements[i]["Amount"]
		var type = requirements[i]["Type"]
		var objective = requirements[i]["Objective"]
		var requirement_node = template_quest_requirement.instance()
		var requirement_label = requirement_node.get_node("Requirement")
		var requirement_amount = requirement_node.get_node("Amount")
		var requirement_check_box = requirement_node.get_node("CheckBox")
		requirement_label.set_text(description)
		if type == "Kill":
			var killed_count = count_killed(type, amount, selected_quest_id)
			requirement_amount.set_text(str(killed_count) + "/" + str(amount))
			if killed_count == amount:
				requirement_check_box.pressed = true
			else:
				requirement_check_box.pressed = false
				
		if type == "Collect":
			var collected_count = count_collected(type, amount, selected_quest_id)
			requirement_amount.set_text(str(collected_count) + "/" + str(amount))
			if collected_count >= amount:
				requirement_check_box.pressed = true
			else:
				requirement_check_box.pressed = false

		requirements_vbox.add_child(requirement_node, true)

func set_quest_rewards(rewards):
	for i in rewards_hbox.get_child_count():
		rewards_hbox.remove_child(rewards_hbox.get_child(0))
	for i in rewards.keys():
		var type_id = rewards[i]["TypeId"]
		var amount = rewards[i]["Amount"]
		var type = rewards[i]["Type"]
		var reward_node = template_quest_reward.instance()
		var reward_label = reward_node.get_node("Label")
		var reward_texture = reward_node.get_node("BackgroundTexture/TextureRect")
		var reward_xp_text = reward_node.get_node("BackgroundTexture/Label")
		if type == "Gold":
			reward_label.set_text(str(amount))
			var gold_texture = load("res://Sprites/Icon_Items/goldcoins.png")
			reward_texture.set_texture(gold_texture)
			
		if type == "Item":
			var item_name = ImportData.item_data[type_id]["Name"]
			reward_label.set_text(item_name)
			var item_texture = load("res://Sprites/Icon_Items/" + item_name + ".png")
			reward_texture.set_texture(item_texture)
		
		if type == "Experience":
			reward_label.set_text(str(amount))
			reward_texture.hide()
			reward_xp_text.show()

		rewards_hbox.add_child(reward_node, true)

func count_killed(type, amount, selected_quest_id):
	var kill_count = 15
	if kill_count > amount:
		kill_count = amount
	return kill_count

func count_collected(type, amount, selected_quest_id):
	return 7

func load_left_panel():
	for i in quest_list_node.get_child_count():
		quest_list_node.remove_child(quest_list_node.get_child(0))
	
	for i in PlayerData.quest_data.keys():
		var accepted = PlayerData.quest_data[i]["Accepted"]
		var abandoned = PlayerData.quest_data[i]["Abandoned"]
		var completed = PlayerData.quest_data[i]["Completed"]
		if (accepted and !abandoned and !completed):
			var quest_title = ImportData.quest_data[i]["Title"]
			var quest_level = ImportData.quest_data[i]["AvailableReqirements"]["PlayerLevel"]
			var quest_requirements_completed = check_quest_requirements_met(i)
			var quest_node = template_quest.instance()
			var quest_check_box = quest_node.get_node("HBoxContainer/CheckBox")
			var quest_level_label = quest_node.get_node("HBoxContainer/Level")
			var quest_title_label = quest_node.get_node("HBoxContainer/Title")
			quest_check_box.pressed = quest_requirements_completed
			quest_level_label.set_text("(" + str(quest_level) + ")")
			quest_title_label.set_text(quest_title)
			quest_list_node.add_child(quest_node, true)

func check_quest_requirements_met(quest_id):
	var requirements = ImportData.quest_data[quest_id]["CompletionRequirements"]
	for i in requirements.keys():
		var type = requirements[i]["Type"]
		var amount = requirements[i]["Amount"]
		var objective = requirements[i]["Objective"]
		if type == "Kill":
			var kill_count = count_killed(type, amount, quest_id)
			if kill_count < amount:
				return false
				
		if type == "Collect":
			var collected_count = count_collected(type, amount, quest_id)
			if collected_count < amount:
				return false
		
	return true

func set_quest_id_from_name(quest_name):
	for i in ImportData.quest_data.keys():
		if ImportData.quest_data[i]["Title"] == quest_name:
			if selected_quest_id == i:
				selected_quest_id = null
			else:
				selected_quest_id = i
			break
	load_right_panel()

func highlight_selected_quest(quest_texture):
	if selected_quest_texture == quest_texture:
		selected_quest_texture.set_modulate(Color(1,1,1))
		selected_quest_texture = null
	else:
		if selected_quest_texture != null:
			selected_quest_texture.set_modulate(Color(1,1,1))
		selected_quest_texture = quest_texture
		selected_quest_texture.set_modulate(Color(0.5,0.5,0.5))


func _on_Cancel_button_up():
	hide()


func _on_Exit_button_up():
	hide()
