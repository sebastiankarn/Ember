extends TextureRect

onready var tool_tip = preload("res://Templates/ToolTip.tscn")
onready var player = get_node("/root/MainScene/Player")
onready var canvas_layer = get_node("/root/MainScene/CanvasLayer")

func get_drag_data(_pos):
	var skill_slot = get_parent().get_name()
	if (skill_slot == "Skill"):
		skill_slot = "Skill1"
	if PlayerData.skills_data[skill_slot]["Id"] != null:
		var data = {}
		data["original_node"] = self
		data["original_panel"] = "SkillPanel"
		data["original_skill_id"] = PlayerData.skills_data[skill_slot]["Id"]
		data["original_texture"] = self.get_node("IconBackground/Icon").texture
	
	
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = self.get_node("IconBackground/Icon").texture
		drag_texture.rect_size = Vector2(60, 60)
		
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)
		
		return data
	


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


