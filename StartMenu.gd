extends Control
const MAIN_SCENE = preload("res://MainScene.tscn")
#LOGIN
@onready var login_container = $NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/LoginContainer
#CREATION
@onready var creation_container = $NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/CreationContainer

func _ready():
	self.show()

func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().quit()

func _on_Login_pressed():
	get_tree().change_scene_to_packed(MAIN_SCENE)

func _on_create_account_pressed():
	login_container.hide()
	creation_container.show()

func _on_back_pressed():
	creation_container.hide()
	login_container.show()
	

func _on_create_new_account_pressed():
	pass # Replace with function body.
