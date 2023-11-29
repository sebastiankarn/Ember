extends TextureButton

@onready var time_label = $Counter/Value
@onready var canvas_layer = get_node("/root/MainScene/CanvasLayer")

func _ready():
	time_label.hide()
	$Sweep.value = 0
	set_process(false)
	
func _process(_delta):
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

func _get_drag_data(_pos):
	var skill_slot = get_parent().get_name()
	if canvas_layer.loaded_skills[skill_slot]["Name"] != null:
		var data = {}
		data["original_node"] = self
		data["original_panel"] = "SkillBar"
		data["original_skill_id"] = canvas_layer.loaded_skills[skill_slot]["Name"]
		data["original_texture"] = self.texture_normal
		data["original_type"] = canvas_layer.loaded_skills[skill_slot]["Type"]
		
	
	
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = self.texture_normal
		drag_texture.size = Vector2(60, 60)
		
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.position = -0.5 * drag_texture.size
		set_drag_preview(control)
		
		return data
		
func _can_drop_data(_pos, data):
	if data["original_panel"] == "Inventory":
		#det är potions/mat eller liknande
		if data["original_stackable"]:
			return true
		else:
			return false
	if data["original_panel"] == "SkillPanel":
		return true
	if data["original_panel"] == "SkillBar":
		return true
	else:
		return false

func _drop_data(_pos, data):
	var target_skill_slot = get_parent().get_name()
	var original_slot = data["original_node"].get_parent().get_name()
	if data["original_node"] == self:
		pass

	else:
		if data["original_panel"] == "Inventory":
			for shortcut in canvas_layer.loaded_skills.keys():
				if canvas_layer.loaded_skills[shortcut]["Name"] == str(data["original_item_id"]) && canvas_layer.loaded_skills[target_skill_slot]["Type"] == "Inventory":
					canvas_layer.loaded_skills[shortcut]["Name"] = null;
			canvas_layer.loaded_skills[target_skill_slot]["Name"] = str(data["original_item_id"])
			canvas_layer.loaded_skills[target_skill_slot]["Type"] = "Item"

		if data["original_panel"] == "SkillPanel":
			for shortcut in canvas_layer.loaded_skills.keys():
				if canvas_layer.loaded_skills[shortcut]["Name"] == data["original_skill_id"] && canvas_layer.loaded_skills[target_skill_slot]["Type"] == "SkillPanel":
					canvas_layer.loaded_skills[shortcut]["Name"] = null;
			canvas_layer.loaded_skills[target_skill_slot]["Name"] = data["original_skill_id"]
			canvas_layer.loaded_skills[target_skill_slot]["Type"] = "Skill"
			
		if data["original_panel"] == "SkillBar":
			canvas_layer.loaded_skills[original_slot]["Name"] = canvas_layer.loaded_skills[target_skill_slot]["Name"]
			canvas_layer.loaded_skills[original_slot]["Type"] = canvas_layer.loaded_skills[target_skill_slot]["Type"]
			canvas_layer.loaded_skills[target_skill_slot]["Name"] = data["original_skill_id"]
			canvas_layer.loaded_skills[target_skill_slot]["Type"] = data["original_type"]
			
	canvas_layer.LoadShortCuts()
