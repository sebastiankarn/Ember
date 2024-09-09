extends Control

@onready var cast_bar : TextureProgressBar = get_node("VBox/CastBar")
@onready var label : Label = get_node("VBox/Name")
var tween

func use_castbar(cast_name, cast_time):
	if tween != null:
		tween.kill()
	tween = create_tween()
	label.set_text(cast_name)
	cast_bar.set_value(0)
	show()
	tween.tween_property(cast_bar, 'value', 100, cast_time)
	tween.tween_callback(hide_castbar)

func hide_castbar():
	hide()
