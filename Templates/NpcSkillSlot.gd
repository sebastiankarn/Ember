extends TextureRect

onready var tool_tip = preload("res://Templates/ToolTip.tscn")
onready var player = get_node("/root/MainScene/Player")
onready var canvas_layer = get_node("/root/MainScene/CanvasLayer")
onready var npc_inventory_window = get_node("/root/MainScene/CanvasLayer/NpcInventory")

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

func right_click(_pos):
	pass

func left_click(_pos):
	var inventory_slot = get_parent().get_name()
	if (inventory_slot == 'Inv'):
		inventory_slot = 'Inv1'
	var npc_name = npc_inventory_window.get_name()
	var npc_inventory = ImportData.npc_data[npc_name]
	var original_texture = get_node("IconBackground/Icon").get_texture()
	var original_price = ImportData.item_data[npc_inventory[inventory_slot]["Item"]]["Cost"]
	var original_name = ImportData.item_data[npc_inventory[inventory_slot]["Item"]]["Name"]
	npc_inventory_window.selected_item_id = npc_inventory[inventory_slot]["Item"]
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/MarginContainer/Label").set_text(original_name)
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/HBoxContainer/TextureRect/Icon").set_texture(original_texture)
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set_text(str(original_price) + " gold")

func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_RIGHT:
				right_click(get_viewport().get_mouse_position())
			BUTTON_LEFT:
				left_click(get_viewport().get_mouse_position())
