extends CPUParticles2D

func _ready():
	emitting = true
	var tween = create_tween()
	tween.tween_property(self, 'modulate', Color.TRANSPARENT, 5)


func _on_delete_timer_timeout():
	queue_free()
