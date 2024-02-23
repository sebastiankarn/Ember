extends Control
const MAIN_SCENE = preload("res://MainScene.tscn")

func _on_play_button_pressed():
	get_tree().change_scene_to_packed(MAIN_SCENE)
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
