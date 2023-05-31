extends Node2D

onready var mouseCursorSkill = get_node("/root/MainScene/CanvasLayer/MouseCursorSkill")
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
	get_node("Sprite").set_modulate(Color(0,0,0))
	var tween = get_tree().create_tween()
	tween.tween_property(get_node("Sprite"), "modulate", Color(1,1,1), 0.5).set_trans(Tween.TRANS_SINE)
	
func _process(delta):
	if (mouseCursorSkill.setAsCursor == true):
		self.hide()
	self.position = self.get_global_mouse_position()
