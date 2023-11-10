extends NinePatchRect
onready var quest_log = get_node("/root/MainScene/CanvasLayer/QuestLog")

func _on_Quest_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				var quest_name = get_node("HBoxContainer/Title").get_text()
				quest_log.set_quest_id_from_name(quest_name)
				quest_log.highlight_selected_quest(self)


