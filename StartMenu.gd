extends Control
const CHARACTER_SELECT_SCENE = preload("res://CharacterSelect.tscn")
#LOGIN
@onready var login_container = $NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/LoginContainer
@onready var user_name_input = $NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/LoginContainer/HBoxContainer/LineEdit
@onready var password_input = $NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/LoginContainer/HBoxContainer2/LineEdit

#CREATION
@onready var creation_container = $NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/CreationContainer
@onready var new_user_name_input = $NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/CreationContainer/HBoxContainer/LineEdit
@onready var new_password_input = $NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/CreationContainer/HBoxContainer2/LineEdit

#ERROR MANAGEMENT
@onready var error_msg_node = $NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/ErrorMsg
@onready var error_margin = $NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/ErrorMargin
@onready var error_timer = $ErrorTimer

func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().quit()

func _on_Login_pressed():
	login()

func _on_create_account_pressed():
	login_container.hide()
	clear_create_account_panel()
	creation_container.show()

func clear_create_account_panel():
	new_user_name_input.text = ""
	new_password_input.text = ""

func _on_back_pressed():
	creation_container.hide()
	user_name_input.text = ""
	password_input.text = ""
	login_container.show()
	

func _on_create_new_account_pressed():
	var new_user_name = new_user_name_input.text
	var new_password = new_password_input.text
	if new_user_name and new_password:
		if !user_exists(new_user_name):
			create_new_user(new_user_name, new_password)
			creation_container.hide()
			clear_create_account_panel()
			login_container.show()
			display_message("Account created!")
		else:
			display_error("User with that username already exists.")
			print("User with that username already exists.")
			new_password_input.text = ""

func create_new_user(user_name, password):
	var saved_login_data:SavedLoginData = SavedLoginData.new()
	saved_login_data.user_name = user_name
	saved_login_data.password = password
	saved_login_data.saved_characters = []
	saved_login_data.highest_character_id = 10001
	
	ResourceSaver.save(saved_login_data, "user://savelogin" + user_name + ".tres")

func user_exists(user_name):
	var file_path = "user://savelogin" + user_name + ".tres"
	if !FileAccess.file_exists(file_path):
		return false
	var saved_login_data:SavedLoginData = load(file_path) as SavedLoginData
	if saved_login_data != null:
		return true
	else:
		return false

func _on_line_edit_text_submitted(new_text):
	if new_text:
		login()

func login():
	var user_name = user_name_input.text
	var password = password_input.text
	if user_name and password:
		load_login_data(user_name, password)

func load_login_data(user_name, password):
	var file_path = "user://savelogin" + user_name + ".tres"
	if !FileAccess.file_exists(file_path):
		display_error("Wrong user name or password!")
		print("Wrong user name or password!")
		password_input.text = ""
		return
		
	var saved_login_data:SavedLoginData = load(file_path) as SavedLoginData
	if saved_login_data == null:
		display_error("Wrong user name or password!")
		print("Wrong user name or password!")
		password_input.text = ""
		return
	
	if !(saved_login_data.password == password):
		display_error("Wrong user name or password!")
		print("Wrong user name or password!")
		password_input.text = ""
		return
	
	PlayerData.user_name = user_name
	PlayerData.characters = saved_login_data.saved_characters
	if !saved_login_data.highest_character_id:
		saved_login_data.highest_character_id = 10001
	PlayerData.highest_character_id = saved_login_data.highest_character_id
	get_tree().change_scene_to_packed(CHARACTER_SELECT_SCENE)

func display_error(error_message):
	error_margin.hide()
	error_msg_node.text = error_message
	error_msg_node.show()
	error_timer.start()

func display_message(message):
	error_margin.hide()
	error_msg_node.text = message
	error_msg_node.set("theme_override_colors/font_color", Color("53dc83"))
	error_msg_node.show()
	error_timer.start()

func _on_error_timer_timeout():
	error_margin.show()
	error_msg_node.set("theme_override_colors/font_color", Color("e7abae"))
	error_msg_node.hide()
