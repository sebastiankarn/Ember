extends Control
@onready var player = get_node("/root/MainScene/Player")

func _ready():
	pass # Replace with function body.
	
func _on_Button_pressed():
	pass # Replace with function body.


func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().quit()


func _on_respawn_pressed():
	player.reset_player()
	get_tree().paused = false
	self.hide()
