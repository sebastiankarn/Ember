extends TextureRect

@onready var tool_tip = preload("res://Templates/ToolTip.tscn")
@onready var player = get_node("/root/MainScene/Player")
@onready var npc_inventory_window = get_node("/root/MainScene/CanvasLayer/NpcInventory")

func _get_drag_data(_pos):
	return
	var skill_slot = get_parent().get_name()
	if PlayerData.skills_data[skill_slot]["Id"] != null:
		var data = {}
		data["original_node"] = self
		data["original_panel"] = "NpcInventory"
		data["original_skill_id"] = PlayerData.skills_data[skill_slot]["Id"]
		data["original_texture"] = self.get_node("IconBackground/Icon").texture


		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = self.get_node("IconBackground/Icon").texture
		drag_texture.size = Vector2(60, 60)

		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.position = -0.5 * drag_texture.size
		set_drag_preview(control)

		return data


func _on_Icon_mouse_entered():
	var tool_tip_instance = tool_tip.instantiate()
	tool_tip_instance.origin = "NpcInventory"
	tool_tip_instance.slot = get_parent().get_name()

	tool_tip_instance.position = get_parent().get_global_transform_with_canvas().origin + Vector2(0, 70)
	#tool_tip_instance.position = tool_tip_instance.position + Vector2(0, 50)
	#tool_tip_instance.position = get_parent().get_global_transform_with_canvas().origin - Vector2(150, 0)

	add_child(tool_tip_instance)
	await get_tree().create_timer(0.35).timeout
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()


func _on_Icon_mouse_exited():
	get_node("ToolTip").free()

func right_click(_pos):
	var inventory_slot = get_parent().get_name()
	if (inventory_slot == 'Inv'):
		inventory_slot = 'Inv1'
	var npc_name = npc_inventory_window.get_npc_name()
	var npc_inventory = ImportData.npc_data[npc_name]
	var item_id = npc_inventory[inventory_slot]["Item"]
	npc_inventory_window.buy_item(item_id)
	var tween = create_tween()
	tween.tween_property(get_parent(), "modulate", Color(0.5,0.5,0.5), 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(get_parent(), "modulate", Color(1,1,1), 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	#var tween = get_node("HBoxContainer/IconBackground/Icon/Tween")
	#tween.interpolate_property(tween.get_parent(), 'modulate', Color(1,1,1), Color(0.5,0.5,0.5), 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	#tween.interpolate_property(tween.get_parent(), 'modulate', Color(0.5,0.5,0.5), Color(1,1,1), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)
	#tween.start()

func left_click(_pos):
	npc_inventory_window.reset_right_panel()
	var inventory_slot = get_parent().get_name()
	if (inventory_slot == 'Inv'):
		inventory_slot = 'Inv1'
	var npc_name = npc_inventory_window.get_npc_name()
	var npc_inventory = ImportData.npc_data[npc_name]
	var original_texture = get_node("HBoxContainer/IconBackground/Icon").get_texture()
	var original_price = ImportData.item_data[npc_inventory[inventory_slot]["Item"]]["Cost"]
	var original_name = ImportData.item_data[npc_inventory[inventory_slot]["Item"]]["Name"]
	var item_id = npc_inventory[inventory_slot]["Item"]
	npc_inventory_window.selected_item_id = item_id

	var info = ImportData.item_data[npc_inventory[inventory_slot]["Item"]]
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
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label").set("theme_override_colors/font_color", Color("dddddd"))
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label2").set("theme_override_colors/font_color", Color("dddddd"))
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/HBoxContainer/TextureRect/Icon").set_texture(original_texture)
	npc_inventory_window.selected_item_price = original_price
	npc_inventory_window.update_gold(false)

	if info != null:
		var item_stat = 1
		var item_data_list = info
		for i in range(ImportData.item_stats.size()):
			var stat_name = ImportData.item_stats[i]
			var stat_label = ImportData.item_stat_labels[i]
			var stat_value = null
			var stat_exists = false
			if item_data_list != null:
				if stat_name in item_data_list:
					stat_exists = true
			if ImportData.item_data[item_id][stat_name] != null or stat_exists:
				stat_value = ImportData.item_data[item_id][stat_name]
				if item_data_list != null:
					if stat_name in item_data_list:
						stat_value = item_data_list[stat_name]
			var equipment_slot = ImportData.item_data[item_id]["EquipmentSlot"]
			if has_stat_of_equipped(equipment_slot, stat_name):
				if stat_value == null:
					stat_value = 0
			if stat_value != null:
				npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Stat").set_text(stat_label + ": "+ str(stat_value))
				if ImportData.item_data[item_id]["EquipmentSlot"] != null:
					var stat_difference = CompareItems(item_id, stat_name, stat_value)
					if stat_difference > 0:
						npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Difference").set_text(" +" + str(stat_difference))
						npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Difference").set("theme_override_colors/font_color", Color("3eff00"))
						npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Difference").show()
					elif stat_difference < 0:
						npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Difference").set_text(" " + str(stat_difference))
						npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Difference").set("theme_override_colors/font_color", Color("ff0000"))
						npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat" + str(item_stat) + "/Difference").show()
				item_stat += 1

	#npc_inventory.window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/RichTextLabel").set_text()

func has_stat_of_equipped(equipment_slot, stat_name):
	if equipment_slot != null:
		if PlayerData.equipment_data[equipment_slot]["Item"] != null:
			var item_id_current = PlayerData.equipment_data[equipment_slot]["Item"]
			var stat_value_current = PlayerData.equipment_data[equipment_slot]["Stats"][stat_name]
			if stat_value_current != null:
				return true
	return false

func _on_Icon_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				right_click(get_viewport().get_mouse_position())
			MOUSE_BUTTON_LEFT:
				left_click(get_viewport().get_mouse_position())

func CompareItems(item_id, stat_name, stat_value):
	var stat_difference
	var equipment_slot = ImportData.item_data[item_id]["EquipmentSlot"]
	if PlayerData.equipment_data[equipment_slot]["Item"] != null:
		var item_id_current = PlayerData.equipment_data[equipment_slot]["Item"]
		var stat_value_current = PlayerData.equipment_data[equipment_slot]["Stats"][stat_name]
		if stat_value_current != null:
			stat_difference = (stat_value - stat_value_current)
		else:
			stat_difference = stat_value
	else:
		stat_difference = stat_value
	return stat_difference
