extends Control
var master_sound = AudioServer.get_bus_index("Master")
@onready var main_scene = get_node("/root/MainScene")
@onready var player = get_node("/root/MainScene/Player")

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


func _on_TextureButton_button_up():
	get_tree().quit()


func _on_save_button_up():
	main_scene.save_game()


func _on_load_button_up():
	main_scene.load_game()


func _on_level_up_pressed() -> void:
	player.level_up()
	print("Level up")


func _on_items_pressed() -> void:
	var counter = 10001
	while counter < 10038:
		if counter != 10007 && counter != 10008 && counter != 10025 && counter != 10006 && counter != 10014 && counter != 10016 && counter != 10018 && counter != 10020 && counter != 10022:
			var item = main_scene.ItemGeneration(str(counter), false)
			player.loot_item(item, null)
		if counter == 10007 || counter == 10008 || counter == 10025 || counter == 10006:
			player.loot_item(str(counter), 999)

		counter = counter + 1
	print("Items")




func _on_teleport_pressed() -> void:
	player.global_position = Vector2(6308, -5590)
	print("Teleport")
