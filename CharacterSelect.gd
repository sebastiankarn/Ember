extends Control
const MAIN_SCENE = preload("res://MainScene.tscn")
var character_slot_scene = preload("res://Templates/CharacterSelectSlot.tscn")
@onready var character_container = $NinePatchRect/NinePatchRect/CharacterSelectContainer/NinePatchRect/VBoxContainer/HBoxContainer2/ScrollContainer/CharacterContainer
@onready var character_select_container = $NinePatchRect/NinePatchRect/CharacterSelectContainer
@onready var character_create_container = $NinePatchRect/NinePatchRect/CharacterCreateContainer
@onready var character_name_input = $NinePatchRect/NinePatchRect/CharacterCreateContainer/VBoxContainer/HBoxContainer/CharacterName
@onready var character_name_label = $NinePatchRect/NinePatchRect/CharacterSelectContainer/VBoxContainer/HBoxContainer/NinePatch/Label
@onready var class_option_button = $NinePatchRect/NinePatchRect/CharacterCreateContainer/VBoxContainer/HBoxContainer3/VBoxContainer/ClassOptionButton
@onready var hair_color_picker = $NinePatchRect/NinePatchRect/CharacterCreateContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HairColorContainer/ColorPickerButton
@onready var skin_color_picker = $NinePatchRect/NinePatchRect/CharacterCreateContainer/VBoxContainer/HBoxContainer3/VBoxContainer/SkinColorContainer/ColorPickerButton
@onready var eye_color_picker = $NinePatchRect/NinePatchRect/CharacterCreateContainer/VBoxContainer/HBoxContainer3/VBoxContainer/EyeColorContainer/ColorPickerButton
var selected_character_node
var saved_characters:Array

func _ready():
	saved_characters = PlayerData.characters
	load_characters()

func reset_clicked_node():
	if selected_character_node != null:
		selected_character_node.reset_node()

func load_characters():
	for i in character_container.get_child_count():
		character_container.remove_child(character_container.get_child(0))
	
	var first_character = true
	for character_id in saved_characters:
		var character_slot = character_slot_scene.instantiate()
		var file_path = "user://savegame" + PlayerData.user_name + str(character_id) + ".tres"
		if !FileAccess.file_exists(file_path):
			return
		var saved_game:SavedGame = load(file_path) as SavedGame
		if saved_game == null:
			return
		var character_name = saved_game.player_data.user_name
		var level = 1
		if saved_game.player_data.player_stats.has("Level"):
			level = saved_game.player_data.player_stats["Level"]
		var profession = saved_game.player_data.profession
		character_slot.character_name = character_name
		character_slot.character_info = "Level " + str(level) + " " + profession
		character_slot.character_id = character_id
		character_container.add_child(character_slot, true)
		if(first_character):
			first_character = false
			character_slot.click_character()

func _on_play_button_pressed():
	PlayerData.character_id = selected_character_node.character_id
	get_tree().change_scene_to_packed(MAIN_SCENE)

func _on_create_pressed():
	var character_name = character_name_input.text
	if !character_name:
		return
	
	var character_class_id = class_option_button.get_selected_id()
	var character_class = class_option_button.get_item_text(character_class_id)
	var character_hair_color = hair_color_picker.color
	var character_skin_color = skin_color_picker.color
	var character_eye_color = eye_color_picker.color
	var character_id = saved_characters.size() + 1
	saved_characters.append(character_id)
	var saved_game:SavedGame = SavedGame.new()
	var saved_player_data:SavedPlayerData = SavedPlayerData.new()
	saved_player_data.user_name = character_name
	saved_player_data.profession = "Mage"
	saved_player_data.character_id = character_id
	saved_game.player_data = saved_player_data
	
	var previous_saved_login_data:SavedLoginData = load("user://savelogin" + PlayerData.user_name + ".tres") as SavedLoginData
	var saved_login_data:SavedLoginData = SavedLoginData.new()
	saved_login_data.user_name = PlayerData.user_name
	saved_login_data.password = previous_saved_login_data.password
	saved_login_data.saved_characters = saved_characters
	
	ResourceSaver.save(saved_login_data, "user://savelogin" + PlayerData.user_name + ".tres")
	ResourceSaver.save(saved_game, "user://savegame" + PlayerData.user_name + str(character_id) + ".tres")
	
	character_create_container.hide()
	character_select_container.show()
	load_characters()

func _on_create_new_pressed():
	character_select_container.hide()
	character_create_container.show()
