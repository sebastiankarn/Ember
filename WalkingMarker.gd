extends Node2D

func _ready():
	queue_redraw()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2,2), 0.1)
	tween.tween_property(self, "scale", Vector2(), 0.5)
	await get_tree().create_timer(1).timeout
	queue_free()

func _draw():
	var center = Vector2(0, 0)
	var color = Color("#ffffffff")
	var radius = 3
	self.draw_circle(center, radius, color)

