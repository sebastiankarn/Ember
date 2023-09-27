extends Sprite

func _ready():
	var tween = get_node("Tween")
	#tween.tween_property(get_node("Icon"), "modulate", Color(1,1,1), 1).set_trans(Tween.TRANS_SINE)
	tween.interpolate_property(self, "modulate", Color(1,1,1), Color.transparent, 1, 3, 1)
	tween.start()



func _on_Tween_tween_completed(object, key):
	queue_free()
