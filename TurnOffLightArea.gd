extends Area2D
@onready var player = get_node("/root/MainScene/Player")
@onready var canvas_modulate = get_node("/root/MainScene/CanvasModulate")

func _on_body_entered(body):
	if body == player:
		turn_off_lights()

func turn_off_lights():
	player.get_node("PointLight2D").show()
	canvas_modulate.show()
