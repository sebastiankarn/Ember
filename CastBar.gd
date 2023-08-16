extends Control

onready var cast_bar : ProgressBar = get_node("VBox/CastBar")
onready var label : Label = get_node("VBox/Name")
onready var tween : Tween = get_node("Tween")

func use_castbar(name, cast_time):
	if tween.is_active():
		tween.reset_all()
	label.set_text(name)
	cast_bar.value = 0
	tween.interpolate_property(cast_bar, 'value', 0, 100, cast_time)
	tween.start()


func _on_Tween_tween_completed(object, key):
	hide()


func _on_Tween_tween_started(object, key):
	show()
