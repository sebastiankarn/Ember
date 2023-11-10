extends Control
onready var quest_title_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/NinePatchRect/Title")
onready var quest_list_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect/ScrollContainer/HBoxContainer/VBoxContainer")
onready var quest_description_node = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/RichTextLabel")
onready var requirements_vbox = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/RequirementsVBox")
onready var right_panel_content = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer")
onready var rewards_hbox = get_node("NinePatchRect/VBoxContainer/HBoxContainer/NinePatchRect2/ScrollContainer/HBoxContainer/VBoxContainer/RewardsHBox")

var selected_quest_id = "10001"

func _ready():
	load_right_panel()

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
	# gör nåt med requirements_vbox
	for i in requirements.keys():
		var description = requirements[i]["Description"]
		var amount = requirements[i]["Amount"]
		var type = requirements[i]["Type"]
		var objective = requirements[i]["Objective"]

func set_quest_rewards(rewards):
	# gör något med rewards_hbox
	for i in rewards.keys():
		var description = rewards[i]["TypeId"]
		var amount = rewards[i]["Amount"]
		var type = rewards[i]["Type"]


func _on_Cancel_button_up():
	hide()


func _on_Exit_button_up():
	hide()
