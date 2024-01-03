extends HBoxContainer
@onready var main_scene = get_node("/root/MainScene")


func _on_backpack_button_button_up():
	main_scene.press_inventory()

func _on_character_button_button_up():
	main_scene.press_character_sheet()


func _on_skills_button_pressed():
	main_scene.press_skills()


func _on_quest_button_pressed():
	main_scene.press_quest_log()


func _on_settings_button_pressed():
	main_scene.press_settings()
