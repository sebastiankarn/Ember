extends Area2D
@onready var player = get_node("/root/MainScene/Player")
@onready var canvas_modulate = get_node("/root/MainScene/CanvasModulate")

func _on_body_entered(body):
	if body == player:
		turn_on_lights()

func turn_on_lights():
	player.get_node("PointLight2D").hide()
	canvas_modulate.hide()
	
