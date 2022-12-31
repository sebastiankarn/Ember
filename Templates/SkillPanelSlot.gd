extends TextureRect

onready var tool_tip = preload("res://Templates/ToolTip.tscn")
onready var player = get_node("/root/MainScene/Player")
onready var canvas_layer = get_node("/root/MainScene/CanvasLayer")

func get_drag_data(_pos):
	var skill_slot = get_parent().get_name()
	if PlayerData.skills_data[skill_slot]["Name"] != null:
		var data = {}
		data["original_node"] = self
		data["original_panel"] = "SkillPanel"
		data["original_skill_id"] = PlayerData.skills_data[skill_slot]["Name"]
		data["original_texture"] = texture
	
	
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = texture
		drag_texture.rect_size = Vector2(60, 60)
		
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)
		
		return data
	
func can_drop_data(_pos, data):
	var target_skill_slot = get_parent().get_name()
	if PlayerData.skills_data[target_skill_slot]["Name"] == null:
		data["target_skill_id"] = null
		data["target_texture"] = null
		data["target_stack"] = null
		return true
	else:
		data["target_skill_id"] = PlayerData.skills_data[target_skill_slot]["Name"]
		data["target_texture"] = texture
		if data["original_panel"] == "CharacterSheet":
			return false
		else:
			return true

func drop_data(_pos, data):
	var target_inv_slot = get_parent().get_name()
	var original_slot = data["original_node"].get_parent().get_name()
	if data["original_node"] == self:
		pass


	else:
		if data["target_item_id"] == data["original_item_id"] and data["original_stackable"] == true:
			PlayerData.inv_data[original_slot]["Item"] = null
			PlayerData.inv_data[original_slot]["Stack"] = null

		elif data["original_panel"] == "Inventory":
			PlayerData.inv_data[original_slot]["Item"] = data["target_item_id"]
			PlayerData.inv_data[original_slot]["Stack"] = data["target_stack"]

		else:
			PlayerData.ChangeEquipment(original_slot, data["target_item_id"])


		if data["target_item_id"] == data["original_item_id"] and data["original_stackable"] == true:
			data["original_node"].texture = null
			data["original_node"].get_node("../Stack").set_text("")

		elif data["original_panel"] == "CharacterSheet" and data["target_item_id"] == null:
			var default_texture = load("res://UI_elements/item_icons/" + original_slot + "_default_icon.webp")
			data["original_node"].texture = default_texture

		else:
			data["original_node"].texture = data["target_texture"]
			if data["target_stack"] != null and data["target_stack"] > 1:
				data["original_node"].get_node("../Stack").set_text(str(data["target_stack"]))
			elif data["original_panel"] == "Inventory":
				data["original_node"].get_node("../Stack").set_text("")

		if data["target_item_id"] == data["original_item_id"] and data["original_stackable"] == true:
			var new_stack = data["target_stack"] + data["original_stack"]
			PlayerData.inv_data[target_inv_slot]["Stack"] = new_stack
			get_node("../Stack").set_text(str(new_stack))


		else:
			PlayerData.inv_data[target_inv_slot]["Item"] = data["original_item_id"]
			texture = data["original_texture"]
			PlayerData.inv_data[target_inv_slot]["Stack"] = data["original_stack"]
			
			if data["original_stack"] != null and data["original_stack"] > 1:
				get_node("../Stack").set_text(str(data["original_stack"]))
			else:
				get_node("../Stack").set_text("")
		canvas_layer.LoadShortCuts()

func _on_Icon_mouse_entered():
	var tool_tip_instance = tool_tip.instance()
	tool_tip_instance.origin = "SkillPanel"
	tool_tip_instance.slot = get_parent().get_name()
	
	tool_tip_instance.rect_position = get_parent().get_global_transform_with_canvas().origin - Vector2(150, 0)

	add_child(tool_tip_instance)
	yield(get_tree().create_timer(0.35), "timeout")
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()
		

func _on_Icon_mouse_exited():
	get_node("ToolTip").free()


