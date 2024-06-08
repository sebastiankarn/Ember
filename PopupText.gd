extends Control
@onready var timer = $Timer
@onready var label = $Label

func show_with_text(text, wait_time, alert):
	var title_color = 'dddddd'
	if alert:
		title_color = 'b70045'
	label.set_text(text)
	label.set("theme_override_colors/font_color", Color(title_color))
	show()

	if (wait_time > 0):
		timer.set_wait_time(wait_time)
		timer.start()
	else:
		timer.stop()


func _on_timer_timeout():
	hide()
