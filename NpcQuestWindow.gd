extends Control
@onready var quest_window_title_node = get_node("NinePatchRect/VBoxContainer/NinePatchRect/Header/TextureRect/Label")
@onready var quest_title_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/NinePatchRect/Title")
@onready var available_quest_list_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect/ScrollContainer/HBoxContainer/VBoxContainer/QuestVBox")
@onready var finished_quest_list_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect/ScrollContainer/HBoxContainer/VBoxContainer/FinishedQuestsVbox")
@onready var quest_description_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/RichTextLabel")
@onready var requirements_vbox = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/RequirementsVBox")
@onready var right_panel_content = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer")
@onready var rewards_hbox = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/RewardsHBox")
@onready var go_to_shop_panel = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer2")
@onready var go_to_shop_button = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer2/Button")
@onready var shop_button = get_node("NinePatchRect/VBoxContainer/NinePatchRect2/Buttons/Shop")
@onready var player = get_node("/root/MainScene/Player")
@onready var npc_inventory = get_node("/root/MainScene/CanvasLayer/NpcInventory")
@onready var quest_log = get_node("/root/MainScene/CanvasLayer/QuestLog")
@onready var complete_button = get_node("NinePatchRect/VBoxContainer/NinePatchRect2/Buttons/Complete")
@onready var accept_button = get_node("NinePatchRect/VBoxContainer/NinePatchRect2/Buttons/Accept")
@onready var finished_quests_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect/ScrollContainer/HBoxContainer/VBoxContainer/FinishedQuestNode")
@onready var available_quests_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect/ScrollContainer/HBoxContainer/VBoxContainer/AvailableQuestsNode")

var template_quest_reward = preload("res://Templates/QuestReward.tscn")
var template_quest_requirement = preload("res://Templates/QuestRequirement.tscn")
var template_quest = preload("res://Templates/QuestWindowQuest.tscn")

var selected_quest_id
var selected_quest_texture
var npc_name

func _ready():
	reload_window()

func reload_window():
	set_window_title()
	load_right_panel()
	load_left_panel()

func set_window_title():
	if npc_name:
		quest_window_title_node.set_text(npc_name)

func load_right_panel():
	if selected_quest_id != null:
		#Load panel
		go_to_shop_panel.hide()
		right_panel_content.show()
		var quest_title = ImportData.quest_data[selected_quest_id]["Title"]
		var quest_description = ImportData.quest_data[selected_quest_id]["Description"]
		var quest_rewards = ImportData.quest_data[selected_quest_id]["Rewards"]
		set_quest_title(quest_title)
		set_quest_description(quest_description)
		set_quest_rewards(quest_rewards)
		if quest_log.check_quest_requirements_met(selected_quest_id):
			accept_button.hide()
			complete_button.show()
		else:
			accept_button.show()
			complete_button.hide()
	else:
		right_panel_content.hide()
		go_to_shop_panel.show()
		accept_button.hide()
		complete_button.hide()

func set_quest_title(title):
	quest_title_node.set_text(title)

func set_quest_description(description):
	quest_description_node.set_text(description)

func set_quest_rewards(rewards):
	for i in rewards_hbox.get_child_count():
		rewards_hbox.remove_child(rewards_hbox.get_child(0))
	for i in rewards.keys():
		var type_id = rewards[i]["TypeId"]
		var amount = rewards[i]["Amount"]
		var type = rewards[i]["Type"]
		var reward_node = template_quest_reward.instantiate()
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

func load_left_panel():
	for i in available_quest_list_node.get_child_count():
		available_quest_list_node.remove_child(available_quest_list_node.get_child(0))
	
	for i in finished_quest_list_node.get_child_count():
		finished_quest_list_node.remove_child(finished_quest_list_node.get_child(0))

	available_quests_node.hide()
	finished_quests_node.hide()
	
	var available_npc_quest_list = get_npc_quests()
	if available_npc_quest_list.size() > 0:
		available_quests_node.show()
	
	for i in available_npc_quest_list:
		var quest_title = ImportData.quest_data[i]["Title"]
		var quest_level = ImportData.quest_data[i]["AvailableReqirements"]["PlayerLevel"]
		var quest_node = template_quest.instantiate()
		var quest_level_label = quest_node.get_node("HBoxContainer/Level")
		var quest_title_label = quest_node.get_node("HBoxContainer/Title")
		quest_level_label.set_text("(" + str(quest_level) + ")")
		quest_title_label.set_text(quest_title)
		available_quest_list_node.add_child(quest_node, true)

	var finished_npc_quest_list = get_finished_npc_quests()
	if finished_npc_quest_list.size() > 0:
		finished_quests_node.show()

	for i in finished_npc_quest_list:
		var quest_title = ImportData.quest_data[i]["Title"]
		var quest_level = ImportData.quest_data[i]["AvailableReqirements"]["PlayerLevel"]
		var quest_node = template_quest.instantiate()
		var quest_level_label = quest_node.get_node("HBoxContainer/Level")
		var quest_title_label = quest_node.get_node("HBoxContainer/Title")
		quest_level_label.set_text("(" + str(quest_level) + ")")
		quest_title_label.set_text(quest_title)
		finished_quest_list_node.add_child(quest_node, true)

func get_finished_npc_quests():
	var finished_npc_quest_list = []
	for i in PlayerData.quest_data.keys():
		var accepted = PlayerData.quest_data[i]["Accepted"]
		var abandoned = PlayerData.quest_data[i]["Abandoned"]
		var completed = PlayerData.quest_data[i]["Completed"]
		if (accepted and !abandoned and !completed):
			var requirements_met = quest_log.check_quest_requirements_met(i)
			if requirements_met:
				finished_npc_quest_list.append(i)
	return finished_npc_quest_list

func get_npc_quests():
	var npc_quests = []
	if player != null:
		var availableQuests = player.getAvailableQuests()
		if npc_name != null:
			for i in availableQuests:
				if ImportData.quest_data[i]["Npc"] == npc_name:
					npc_quests.append(i)
	return npc_quests

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

func open_shop():
	hide()
	npc_inventory.npc_name = npc_name
	npc_inventory.open_shop()

func accept_quest():
	if selected_quest_id:
		PlayerData.quest_data[selected_quest_id]["Accepted"] = true
		start_quest_tracking(selected_quest_id)
		selected_quest_id = null
		load_left_panel()
		load_right_panel()
		quest_log.reset_quest_log()
		player.checkAvailableQuests()

func complete_quest():
	if selected_quest_id:
		PlayerData.quest_data[selected_quest_id]["Completed"] = true
		stop_quest_tracking(selected_quest_id)
		receive_quest_rewards(selected_quest_id)
		selected_quest_id = null
		load_left_panel()
		load_right_panel()
		quest_log.reset_quest_log()

func stop_quest_tracking(quest_id):
	var talk_quests = PlayerData.quest_requirements_tracking["Talk"]
	var kill_quests = PlayerData.quest_requirements_tracking["Kill"]
	var collect_quests = PlayerData.quest_requirements_tracking["Collect"]
	for i in talk_quests.keys():
		if quest_id in talk_quests[i].keys():
			talk_quests[i][quest_id] = null
	for i in kill_quests.keys():
		if quest_id in kill_quests[i].keys():
			kill_quests[i][quest_id] = null
	for i in collect_quests.keys():
		if quest_id in collect_quests[i].keys():
			collect_quests[i][quest_id] = null

func receive_quest_rewards(quest_id):
	var quest_rewards = ImportData.quest_data[quest_id]["Rewards"]
	for i in quest_rewards.keys():
		var type = quest_rewards[i]["Type"]
		var type_id = quest_rewards[i]["TypeId"]
		var amount = quest_rewards[i]["Amount"]
		if type == "Item":
			player.loot_item(type_id, amount)
		if type == "Experience":
			player.give_xp(amount)
		if type == "Gold":
			player.give_gold(amount)

func start_quest_tracking(quest_id):
	var talk_quests = PlayerData.quest_requirements_tracking["Talk"]
	var kill_quests = PlayerData.quest_requirements_tracking["Kill"]
	var collect_quests = PlayerData.quest_requirements_tracking["Collect"]
	for i in talk_quests.keys():
		if quest_id in talk_quests[i].keys():
			talk_quests[i][quest_id] = false
	for i in kill_quests.keys():
		if quest_id in kill_quests[i].keys():
			kill_quests[i][quest_id] = 0
	for i in collect_quests.keys():
		if quest_id in collect_quests[i].keys():
			var item_count = player.item_count_in_inventory("Name", i)
			collect_quests[i][quest_id] = item_count
		

func _on_Exit_button_up():
	hide()


func _on_Accept_button_up():
	accept_quest()

func _on_Shop_button_up():
	open_shop()


func _on_Cancel_button_up():
	hide()


func _on_Button_button_up():
	open_shop()


func _on_Complete_button_up():
	complete_quest()
