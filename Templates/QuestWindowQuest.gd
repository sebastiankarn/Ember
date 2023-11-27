extends NinePatchRect

onready var npc_quest_window = get_node("/root/MainScene/CanvasLayer/NpcQuestWindow")

func _on_QuestWindowQuest_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				var quest_name = get_node("HBoxContainer/Title").get_text()
				npc_quest_window.set_quest_id_from_name(quest_name)
				npc_quest_window.highlight_selected_quest(self)
