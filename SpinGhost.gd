extends Sprite2D

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_callback(queue_free)

