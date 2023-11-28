extends Control

@onready var cast_bar : ProgressBar = get_node("VBox/CastBar")
@onready var label : Label = get_node("VBox/Name")
var is_casting = false

func use_castbar(name, cast_time):
	var tween = create_tween()
	#if tween.is_active():
	#	tween.reset_all()
	label.set_text(name)
	cast_bar.value = 0
	show()
	tween.tween_property(cast_bar, 'value', 100, cast_time)
	tween.tween_callback(hide_castbar)

func hide_castbar():
	hide()
