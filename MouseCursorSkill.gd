extends Node2D

@onready var mouseCursorAttack = get_node("/root/MainScene/CanvasLayer/MouseCursorAttack")
var setAsCursor = false

func set_as_cursor():
	setAsCursor = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	self.show()
	
func reset_cursor():
	setAsCursor = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.hide()
	
func click():
	get_node("Sprite2D").set_modulate(Color(0,0,0))
	var tween = create_tween()
	tween.tween_property(get_node("Sprite2D"), "modulate", Color(1,1,1), 0.5).set_trans(Tween.TRANS_SINE)
	
func _process(delta):
	self.position = self.get_global_mouse_position()
