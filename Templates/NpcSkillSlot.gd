extends TextureRect

onready var tool_tip = preload("res://Templates/ToolTip.tscn")
onready var player = get_node("/root/MainScene/Player")
onready var canvas_layer = get_node("/root/MainScene/CanvasLayer")
onready var npc_inventory_window = get_node("/root/MainScene/CanvasLayer/NpcInventory")

func get_drag_data(_pos):
	return
	var skill_slot = get_parent().get_name()
	if (skill_slot == "Skill"):
		skill_slot = "Skill1"
	if PlayerData.skills_data[skill_slot]["Id"] != null:
		var data = {}
		data["original_node"] = self
		data["original_panel"] = "NpcSkillPanel"
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
	tool_tip_instance.origin = "NpcSkillPanel"
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
	npc_inventory_window.reset_right_panel()
	var inventory_slot = get_parent().get_name()
	if (inventory_slot == 'Inv'):
		inventory_slot = 'Inv1'
	print(inventory_slot)
	var npc_name = npc_inventory_window.get_name()
	var npc_inventory = ImportData.npc_data[npc_name]
	var original_texture = get_node("IconBackground/Icon").get_texture()
	var original_price = ImportData.skill_data [npc_inventory[inventory_slot]["Id"]]["SkillCost"]
	var original_name = ImportData.skill_data[npc_inventory[inventory_slot]["Id"]]["SkillName"]
	var skill_id = npc_inventory[inventory_slot]["Id"]
	var info = ImportData.skill_data[skill_id]
	npc_inventory_window.selected_item_id = skill_id
	if (original_name.length() > 16):
		var words_array = original_name.split(" ")
		var too_long = 0
		var first_row_string = ""
		var second_row_string = ""
		var on_first_row = true
		for i in words_array:
			if on_first_row:
				too_long += i.length() + 1
				if too_long >= 16:
					on_first_row = false
					second_row_string += i
				else:
					if (first_row_string == ""):
						first_row_string += i
					else:
						first_row_string += " " + i
			else:
				second_row_string += " " + i
		if (second_row_string == ""):
			npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label2").set_text("")
			npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label2").hide()
			npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label").set_text(original_name)
		else:
			npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label2").set_text(first_row_string)
			npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label2").show()
			npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label").set_text(second_row_string)
	else:
		npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label2").set_text("")
		npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label2").hide()
		npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label").set_text(original_name)
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label").set("custom_colors/font_color", Color("dddddd"))
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label2").set("custom_colors/font_color", Color("dddddd"))
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/HBoxContainer/TextureRect/Icon").set_texture(original_texture)
	npc_inventory_window.selected_item_price = original_price
	npc_inventory_window.update_gold(false)
	
	if info != null:
		var item_stat = 1
		var item_data_list = info
		for i in range(ImportData.skill_stats.size()):
			var stat_name = ImportData.skill_stats[i]
			var stat_label = ImportData.skill_stat_labels[i]
			var stat_value = null
			var stat_exists = false
			if item_data_list != null:
				if stat_name in item_data_list:
					stat_exists = true
			if ImportData.skill_data[skill_id][stat_name] != null or stat_exists:
				stat_value = ImportData.skill_data[skill_id][stat_name]
				if item_data_list != null:
					if stat_name in item_data_list:
						stat_value = item_data_list[stat_name]
			if stat_value != null:
				if (stat_label == "Required level"):
					if (stat_value > PlayerData.player_stats["Level"]):
						npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Stat").set("custom_colors/font_color", Color("ff0000"))
					else:
						npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Stat").set("custom_colors/font_color", Color("83df65"))
				else:
					npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Stat").set("custom_colors/font_color", Color("dddddd"))
				npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Stat").set_text(stat_label + ": "+ str(stat_value))
				item_stat += 1

func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_RIGHT:
				right_click(get_viewport().get_mouse_position())
			BUTTON_LEFT:
				left_click(get_viewport().get_mouse_position())
