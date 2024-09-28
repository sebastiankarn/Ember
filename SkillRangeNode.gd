extends Node2D
var radius = 0

func _draw():
	var center = Vector2(0, 0)
	var color = Color("#ffffff78")
	self.draw_circle(center, radius, color)
