extends Control
@onready var player = get_node("/root/MainScene/Player")
@onready var characterSheet = get_node("/root/MainScene/CanvasLayer/CharacterSheet")

func _ready():
	self.show()
	pass # Replace with function body.

func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().quit()

func _on_Login_pressed():
	hide()
	player.user_name = get_node("NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/HBoxContainer/LineEdit").get_text()
	characterSheet._ready()
	player.get_node("HealthBar")._ready()
