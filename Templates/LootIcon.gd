extends TextureRect

func _ready():
	get_node("Timer").start()
	get_node("Icon").set_modulate(Color.TRANSPARENT)
	var tween = get_tree().create_tween()
	tween.tween_property(get_node("Icon"), "modulate", Color(1,1,1), 1).set_trans(Tween.TRANS_SINE)

func _on_Timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(get_node("Icon"), "modulate", Color.TRANSPARENT, 1).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(Callable(self, "release_node"))
	
func release_node():
	queue_free()
