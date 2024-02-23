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

func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().quit()

func _on_Login_pressed():
	login()

func _on_create_account_pressed():
	login_container.hide()
	new_user_name_input.text = ""
	new_password_input.text = ""
	creation_container.show()

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
		else:
			print("User with that username already exists.")
			new_password_input.text = ""

func create_new_user(user_name, password):
	var saved_login_data:SavedLoginData = SavedLoginData.new()
	saved_login_data.user_name = user_name
	saved_login_data.password = password
	saved_login_data.saved_characters = []
	
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
		var loaded_data = load_login_data(user_name, password)

func load_login_data(user_name, password):
	var file_path = "user://savelogin" + user_name + ".tres"
	if !FileAccess.file_exists(file_path):
		print("Wrong user name or password!")
		password_input.text = ""
		return
		
	var saved_login_data:SavedLoginData = load(file_path) as SavedLoginData
	if saved_login_data == null:
		print("Wrong user name or password!")
		password_input.text = ""
		return
	
	if !(saved_login_data.password == password):
		print("Wrong user name or password!")
		password_input.text = ""
		return
	
	PlayerData.user_name = user_name
	PlayerData.characters = saved_login_data.saved_characters
	get_tree().change_scene_to_packed(CHARACTER_SELECT_SCENE)
