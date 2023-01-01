extends TextureButton

onready var time_label = $Counter/Value
onready var canvas_layer = get_node("/root/MainScene/CanvasLayer")

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

func can_drop_data(_pos, data):
	if data["original_panel"] == "Inventory":
		#det är potions/mat eller liknande
		if data["original_stack"]:
			return true
		else:
			return false
	if data["original_panel"] == "SkillPanel":
		return true
	else:
		return false

func drop_data(_pos, data):
	var target_skill_slot = get_parent().get_name()
	var original_slot = data["original_node"].get_parent().get_name()
	if data["original_node"] == self:
		pass

	else:
		if data["original_panel"] == "Inventory":
			PlayerData.inv_data[original_slot]["Item"] = data["target_item_id"]
			PlayerData.inv_data[original_slot]["Stack"] = data["target_stack"]
			print(data)

		if data["original_panel"] == "SkillPanel":
			for shortcut in canvas_layer.loaded_skills.keys():
				if canvas_layer.loaded_skills[shortcut] == data["original_skill_id"]:
					canvas_layer.loaded_skills[shortcut] = null;
			canvas_layer.loaded_skills[target_skill_slot] = data["original_skill_id"]
			
	canvas_layer.LoadShortCuts()
