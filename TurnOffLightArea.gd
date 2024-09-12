extends Area2D
@onready var player = get_node("/root/MainScene/Player")
@onready var canvas_modulate = get_node("/root/MainScene/CanvasModulate")
@onready var main_scene = get_node("/root/MainScene")

func _on_body_entered(body):
	print("offlight")
	if body == player:
		main_scene.turn_off_light()
