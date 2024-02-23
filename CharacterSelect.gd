extends Control
@onready var main_scene = get_node("/root/MainScene")
@onready var player = get_node("/root/MainScene/Player")
@onready var characterSheet = get_node("/root/MainScene/CanvasLayer/CharacterSheet")
var selected_character_id = 1
var saved_characters

func _on_play_button_pressed():
	player.character_id = selected_character_id
	main_scene.load_game()
	hide()

func get_character_name(character_id):
	return 1
	#SET CHARACTER NAME
	#LOAD SAVED FILE
	#var new_user_name = get_node("NinePatchRect/NinePatchRect/NinePatchRect/VBoxContainer/HBoxContainer/LineEdit").get_text()
	#player.user_name = new_user_name
	#player.get_node("HealthBar/VBoxContainer/Name").set_text(new_user_name)
	#Sätt player ID
	
	#INSPO FÖR STARTSCENEN
	#var auto_projectile = load("res://RangedSingleTargetTargetedSkill.tscn")
	#var projectile_instance = auto_projectile.instantiate()
	#projectile_instance.get_node("PointLight2D").color = Color("6ae7f0")
	#projectile_instance.skill_name = "10016"
	
	
	#LADDA IN CHARACTERS.
	#INLOGG BEHÖVER USERNAME + PASSWORD OCH CHARACTER IDS
	
	
#func _on_Quit_pressed():
#	get_tree().paused = false
#	get_tree().quit()
