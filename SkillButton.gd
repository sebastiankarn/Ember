extends TextureButton

onready var time_label = $Counter/Value

func _ready():
	time_label.hide()
	$Sweep.value = 0
	set_process(false)
	
func _process(delta):
	time_label.text = "%3.1f" % $Sweep/Timer.time_left
	$Sweep.value = int(($Sweep/Timer.time_left / $Sweep/Timer.wait_time) * 100)
	


func _on_Timer_timeout():
	$Sweep.value = 0
	disabled = false
	time_label.hide()
	set_process(false)

func start_cooldown():
	disabled = true
	set_process(true)
	$Sweep/Timer.start()
	time_label.show()

func _on_TextureButton_pressed():
	disabled = true
	set_process(true)
	$Sweep/Timer.start()
	time_label.show()
