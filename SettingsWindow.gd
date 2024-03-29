extends Control
var master_sound = AudioServer.get_bus_index("Master")
@onready var main_scene = get_node("/root/MainScene")

func _ready():
	var volume_slider = get_node("NinePatchRect/VBoxContainer/VBoxContainer/HBoxContainer2/CheckButton")
	var current_volume = AudioServer.get_bus_volume_db(master_sound)
	volume_slider.value = db_to_linear(current_volume)

func _on_Exit_button_up():
	hide()

func _on_Cancel_button_up():
	hide()


func _on_CheckButton_button_up():
	var is_muted = AudioServer.is_bus_mute(master_sound)
	AudioServer.set_bus_mute(master_sound, !is_muted)

func _on_CheckButton_value_changed(value):
	AudioServer.set_bus_volume_db(master_sound, linear_to_db(value))


func _on_CheckButton_item_selected(index):
	var check_button = get_node("NinePatchRect/VBoxContainer/VBoxContainer/HBoxContainer3/CheckButton")
	var selected_resolution = check_button.get_item_text(index)
	var resolution_dimensions = selected_resolution.split("x")
	ProjectSettings.set_setting("display/window/size/viewport_width", resolution_dimensions[0])
	ProjectSettings.set_setting("display/window/size/viewport_height", resolution_dimensions[1])


func _on_TextureButton_button_up():
	get_tree().quit()


func _on_save_button_up():
	main_scene.save_game()


func _on_load_button_up():
	main_scene.load_game()
