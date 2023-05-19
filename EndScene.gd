extends Control
onready var player = get_node("/root/MainScene/Player")

func _ready():
	pass # Replace with function body.
	
func _on_Button_pressed():
	pass # Replace with function body.

func _on_Respawn_pressed():
	#var player_resource = load("res://Player.tscn")
	#var player = player_resource.instance()
	#get_node("/root/MainScene").add_child(player)
	print("LOL")
	player.reset_player()
	get_tree().paused = false
	self.hide()

func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().quit()
