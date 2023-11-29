extends Control
@onready var player = get_node("/root/MainScene/Player")
@onready var characterSheet = get_node("/root/MainScene/CanvasLayer/CharacterSheet")

func _ready():
	self.show()

func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().quit()

func _on_Login_pressed():
	hide()
	var new_user_name = get_node("NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/HBoxContainer/LineEdit").get_text()
	player.user_name = new_user_name
	player.get_node("HealthBar/Name").set_text(new_user_name)
