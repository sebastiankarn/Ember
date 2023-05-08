extends TextureRect

onready var tool_tip = preload("res://Templates/ToolTip.tscn")
onready var split_popup = preload("res://Templates/ItemSplitPopup.tscn")
onready var player = get_node("/root/MainScene/Player")
onready var canvas_layer = get_node("/root/MainScene/CanvasLayer")
onready var time_label = get_node("Counter/Value")
onready var npc_inventory_window = get_node("/root/MainScene/CanvasLayer/NpcInventory")

func _process(delta):
	time_label.text = "%3.1f" % $Sweep/Timer.time_left
	$Sweep.value = int(($Sweep/Timer.time_left / $Sweep/Timer.wait_time) * 100)

func _on_Timer_timeout():
	$Sweep.value = 0
	time_label.hide()
	set_process(false)

func start_cooldown():
	set_process(true)
	$Sweep/Timer.start()
	time_label.show()


func use_click(_pos):
	var inventory_slot = get_parent().get_name()
	var data = {}
	if PlayerData.inv_data[inventory_slot]["Item"] != null:
		data["original_node"] = self
		data["original_panel"] = "Inventory"
		data["original_stats"] = PlayerData.inv_data[inventory_slot]["Stats"]
		data["original_info"] = PlayerData.inv_data[inventory_slot]["Info"]
		data["original_item_id"] = PlayerData.inv_data[inventory_slot]["Item"]
		data["original_inventory_slot"] = inventory_slot
		data["original_item"] = PlayerData.inv_data[inventory_slot]
		data["original_stackable"] = false
		data["original_stack"] = 1
		data["original_texture"] = texture
	else:
		#Har ingenting att använda
		return
	
	#Kan använda den
	var original_item = data["original_item"]
	var item_equipment_slot = ImportData.item_data[str(original_item["Item"])]["EquipmentSlot"]
	var item_category = ImportData.item_data[str(original_item["Item"])]["Category"]
	if item_equipment_slot != null:
		#Går att equippa
		var master_node = get_node("/root/MainScene/CanvasLayer/CharacterSheet/VBoxContainer/HBoxContainer/VBoxContainer/Equipment/HBoxContainer")
		var target_node = master_node.find_node(str(item_equipment_slot), true, true)
		var already_equipped = PlayerData.equipment_data[item_equipment_slot]["Item"]
		var already_equipped_info = PlayerData.equipment_data[item_equipment_slot]["Info"]
		var already_equipped_stats = PlayerData.equipment_data[item_equipment_slot]["Stats"]
		if already_equipped != null:
			#Något equippat redan
			PlayerData.inv_data[inventory_slot]["Item"] = already_equipped
			PlayerData.inv_data[inventory_slot]["Stack"] = 1
			PlayerData.inv_data[inventory_slot]["Info"] = already_equipped_info
			PlayerData.inv_data[inventory_slot]["Stats"] = already_equipped_stats
			
			texture = target_node.get_node("Icon").texture
			get_node("Sweep").texture_progress = target_node.get_node("Icon").texture
			get_node("Sweep/Timer").wait_time = 20
			get_node("../Stack").set_text("")

		else:
			#Inget equippat
			PlayerData.inv_data[inventory_slot]["Item"] = null
			PlayerData.inv_data[inventory_slot]["Stack"] = null
			texture = null
			get_node("Sweep").texture_progress = null
			get_node("Sweep/Timer").wait_time = 0
		PlayerData.ChangeEquipment(item_equipment_slot, data["original_item_id"], data["original_stats"], data["original_info"])
		target_node.get_node("Icon").texture = data["original_texture"]
		
	elif item_category == "Potion":
		var potion_health = ImportData.item_data[str(original_item["Item"])]["PotionHealth"]
		var potion_mana = ImportData.item_data[str(original_item["Item"])]["PotionMana"]
		var stack = PlayerData.inv_data[inventory_slot]["Stack"]
		if potion_health != null:
			player.OnHeal(potion_health)
			
		if potion_mana != null:
			player.mana_boost(potion_mana)
		#Går inte att använda men något där
		if stack > 2:
			PlayerData.inv_data[inventory_slot]["Stack"] -= 1
			get_node("../Stack").set_text(str(stack - 1))
		if stack == 2:
			PlayerData.inv_data[inventory_slot]["Stack"] -= 1
			get_node("../Stack").set_text("")
		if stack == 1:
			PlayerData.inv_data[inventory_slot]["Item"] = null
			PlayerData.inv_data[inventory_slot]["Stack"] = null
			texture = null
			get_node("Sweep").texture_progress = null
			get_node("Sweep/Timer").wait_time = 0
			
	elif item_category == "Food":
		if player.eating == false:
			player.eating = true
			start_cooldown()
			var shortcut_node
			for shortcut in canvas_layer.loaded_skills.keys():
				if str(canvas_layer.loaded_skills[shortcut]["Name"]) == str(original_item["Item"]):
					shortcut_node = canvas_layer.get_node("SkillBar/Background/HBoxContainer/" + shortcut + "/TextureButton")
					shortcut_node.start_cooldown()
			for inventory_item in PlayerData.inv_data.keys():
				if str(PlayerData.inv_data[inventory_item]["Item"]) == str(original_item["Item"]):
					get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer/" + inventory_item + "/Icon").start_cooldown()
			var satiation =  ImportData.item_data[str(original_item["Item"])]["FoodSatiation"]
			var stack = PlayerData.inv_data[inventory_slot]["Stack"]
			if satiation != null:
				player.heal_over_time(satiation, 20, true)
			if stack > 2:
				PlayerData.inv_data[inventory_slot]["Stack"] -= 1
				get_node("../Stack").set_text(str(stack - 1))
			if stack == 2:
				PlayerData.inv_data[inventory_slot]["Stack"] -= 1
				get_node("../Stack").set_text("")
			if stack == 1:
				PlayerData.inv_data[inventory_slot]["Item"] = null
				PlayerData.inv_data[inventory_slot]["Stack"] = null
				texture = null
				get_node("Sweep").texture_progress = null
				get_node("Sweep/Timer").wait_time = 0
				get_node("Counter/Value").hide()
				
	elif item_category == "Drink":
		if player.drinking == false:
			var shortcut_node
			for shortcut in canvas_layer.loaded_skills.keys():
				if str(canvas_layer.loaded_skills[shortcut]["Name"]) == str(original_item["Item"]):
					shortcut_node = canvas_layer.get_node("SkillBar/Background/HBoxContainer/" + shortcut + "/TextureButton")
					shortcut_node.start_cooldown()
			for inventory_item in PlayerData.inv_data.keys():
				if str(PlayerData.inv_data[inventory_item]["Item"]) == str(original_item["Item"]):
					get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer/" + inventory_item + "/Icon").start_cooldown()
			player.drinking = true
			var satiation =  ImportData.item_data[str(original_item["Item"])]["FoodSatiation"]
			var stack = PlayerData.inv_data[inventory_slot]["Stack"]
			if satiation != null:
				player.mana_over_time(satiation, 20, true)
			if stack > 2:
				PlayerData.inv_data[inventory_slot]["Stack"] -= 1
				get_node("../Stack").set_text(str(stack - 1))
			if stack == 2:
				PlayerData.inv_data[inventory_slot]["Stack"] -= 1
				get_node("../Stack").set_text("")
			if stack == 1:
				PlayerData.inv_data[inventory_slot]["Item"] = null
				PlayerData.inv_data[inventory_slot]["Stack"] = null
				texture = null
				get_node("Sweep").texture_progress = null
				get_node("Sweep/Timer").wait_time = 0
				get_node("Counter/Value").hide()
	canvas_layer.LoadShortCuts()
	
func get_drag_data(_pos):
	var inv_slot = get_parent().get_name()
	if PlayerData.inv_data[inv_slot]["Item"] != null:
		var data = {}
		data["original_node"] = self
		data["original_panel"] = "Inventory"
		data["original_item_id"] = PlayerData.inv_data[inv_slot]["Item"]
		data["original_equipment_slot"] = ImportData.item_data[str(PlayerData.inv_data[inv_slot]["Item"])]["EquipmentSlot"]
		data["original_stackable"] = ImportData.item_data[str(PlayerData.inv_data[inv_slot]["Item"])]["Stackable"]
		data["original_stack"] = PlayerData.inv_data[inv_slot]["Stack"]
		data["original_texture"] = texture
		data["original_sweep"] = get_node("Sweep")
		data["original_counter"] = get_node("Counter")
		data["original_info"] = PlayerData.inv_data[inv_slot]["Info"]
		data["original_stats"] = PlayerData.inv_data[inv_slot]["Stats"]
	
	
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
	var target_inv_slot = get_parent().get_name()
	if PlayerData.inv_data[target_inv_slot]["Item"] == null:
		data["target_item_id"] = null
		data["target_texture"] = null
		data["target_stack"] = null
		data["target_info"] = null
		data["target_stats"] = null
		return true
	else:
		if Input.is_action_pressed("secondary"):
			return false
		else:
			data["target_item_id"] = PlayerData.inv_data[target_inv_slot]["Item"]
			data["target_texture"] = texture
			data["target_stack"] = PlayerData.inv_data[target_inv_slot]["Stack"]
			data["target_info"] = PlayerData.inv_data[target_inv_slot]["Info"]
			data["target_stats"] = PlayerData.inv_data[target_inv_slot]["Stats"]
			if data["original_panel"] == "CharacterSheet":
				var target_equipment_slot = ImportData.item_data[str(PlayerData.inv_data[target_inv_slot]["Item"])]["EquipmentSlot"]
				if target_equipment_slot == data["original_equipment_slot"]:
					return true
				else:
					return false
			else:
				return true
	
func drop_data(_pos, data):
	var target_inv_slot = get_parent().get_name()
	var original_slot = data["original_node"].get_parent().get_name()
	if data["original_node"] == self:
		pass

	elif Input.is_action_pressed("secondary") and data["original_panel"] == "Inventory" and data["original_stack"] > 1:
		var split_popup_instance = split_popup.instance()
		split_popup_instance.rect_position = get_parent().get_global_transform_with_canvas().origin + Vector2(0, 60)
		split_popup_instance.data = data
		add_child(split_popup_instance)
		get_node("ItemSplitPopup").show()

	else:
		if data["target_item_id"] == data["original_item_id"] and data["original_stackable"] == true:
			PlayerData.inv_data[original_slot]["Item"] = null
			PlayerData.inv_data[original_slot]["Stack"] = null

		elif data["original_panel"] == "Inventory":
			PlayerData.inv_data[original_slot]["Item"] = data["target_item_id"]
			PlayerData.inv_data[original_slot]["Stack"] = data["target_stack"]
			PlayerData.inv_data[original_slot]["Info"] = data["target_info"]
			PlayerData.inv_data[original_slot]["Stats"] = data["target_stats"]

		else:
			PlayerData.ChangeEquipment(original_slot, data["target_item_id"], data["target_stats"], data["target_info"])


		if data["target_item_id"] == data["original_item_id"] and data["original_stackable"] == true:
			data["original_node"].texture = null
			data["original_node"].get_node("Sweep").texture_progress = null
			data["original_node"].get_node("Sweep/Timer").wait_time = 0
			data["original_node"].get_node("../Stack").set_text("")

		elif data["original_panel"] == "CharacterSheet" and data["target_item_id"] == null:
			var default_texture = load("res://UI_elements/item_icons/" + original_slot + "_default_icon.webp")
			data["original_node"].texture = default_texture
			data["original_node"].get_node("Sweep").texture_progress = default_texture
			data["original_node"].get_node("Sweep/Timer").wait_time = 20

		else:
			data["original_node"].texture = data["target_texture"]
			data["original_node"].get_node("Sweep").texture_progress = data["target_texture"]
			data["original_node"].get_node("Sweep/Timer").wait_time = 20
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
			get_node("Sweep").texture_progress = data["original_texture"]
			get_node("Sweep/Timer").wait_time = 20
			PlayerData.inv_data[target_inv_slot]["Stack"] = data["original_stack"]
			PlayerData.inv_data[target_inv_slot]["Info"] = data["original_info"]
			PlayerData.inv_data[target_inv_slot]["Stats"] = data["original_stats"]
			
			
			if data["original_stack"] != null and data["original_stack"] > 1:
				get_node("../Stack").set_text(str(data["original_stack"]))
			else:
				get_node("../Stack").set_text("")
		
		canvas_layer.LoadShortCuts()

func SplitStack(split_amount, data):
	var target_inv_slot = get_parent().get_name()
	var original_slot = data["original_node"].get_parent().get_name()

	PlayerData.inv_data[original_slot]["Stack"] = data["original_stack"] - split_amount
	PlayerData.inv_data[target_inv_slot]["Item"] = data["original_item_id"]
	PlayerData.inv_data[target_inv_slot]["Stack"] = split_amount
	texture = data["original_texture"]
	get_node("Sweep").texture_progress = data["original_texture"]
	get_node("Sweep/Timer").wait_time = 20

	if data["original_stack"] - split_amount > 1:
		data["original_node"].get_node("../Stack").set_text(str(data["original_stack"] - split_amount))
	else:
		data["original_node"].get_node("../Stack").set_text("")

	if split_amount > 1:
		get_node("../Stack").set_text(str(split_amount))
	else:
		get_node("../Stack").set_text("")


func _on_Icon_mouse_entered():
	var tool_tip_instance = tool_tip.instance()
	tool_tip_instance.origin = "Inventory"
	tool_tip_instance.slot = get_parent().get_name()
	
	tool_tip_instance.rect_position = get_parent().get_global_transform_with_canvas().origin - Vector2(150, 0)

	add_child(tool_tip_instance)
	yield(get_tree().create_timer(0.35), "timeout")
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()
		

func _on_Icon_mouse_exited():
	get_node("ToolTip").free()

func right_click(_pos):
	var inventory_slot = get_parent().get_name()
	var price = calculate_price(inventory_slot)
	npc_inventory_window.sell_item(inventory_slot, price)

func calculate_price(inventory_slot):
	var original_price  = ImportData.item_data[PlayerData.inv_data[inventory_slot]["Item"]]["SellCost"]
	var item_rarity
	var prefix
	var suffix
	var prefix_multiplier = 0
	var suffix_multiplier = 0
	var item_rarity_multiplier = 0
	if (PlayerData.inv_data[inventory_slot]["Info"] != null):
		item_rarity = PlayerData.inv_data[inventory_slot]["Info"]["item_rarity"]
		if (PlayerData.inv_data[inventory_slot]["Info"]["magical"]):
			prefix = PlayerData.inv_data[inventory_slot]["Info"]["prefix"]
			suffix = PlayerData.inv_data[inventory_slot]["Info"]["suffix"]
	if (prefix != null):
		prefix_multiplier = original_price * 0.3
	if (suffix != null):
		suffix_multiplier = original_price * 0.3
	if (item_rarity == "Uncommon"):
		item_rarity_multiplier = original_price * 0.2
	elif (item_rarity == "Rare"):
		item_rarity_multiplier = original_price * 0.3
	elif (item_rarity == "Epic"):
		item_rarity_multiplier = original_price * 0.7
	elif (item_rarity == "Legendary"):
		item_rarity_multiplier = original_price * 1.2
	return original_price + prefix_multiplier + suffix_multiplier + item_rarity_multiplier

func left_click(_pos):
	var inventory_slot = get_parent().get_name()
	var original_texture = get_texture()
	var original_name = ImportData.item_data[PlayerData.inv_data[inventory_slot]["Item"]]["Name"]
	npc_inventory_window.selected_item_id = PlayerData.inv_data[inventory_slot]["Item"]
	var info = PlayerData.inv_data[inventory_slot]["Info"]
	var item_rarity
	var prefix
	var suffix
	var title_color = "dddddd"
	if (PlayerData.inv_data[inventory_slot]["Info"] != null):
		item_rarity = PlayerData.inv_data[inventory_slot]["Info"]["item_rarity"]
		if (PlayerData.inv_data[inventory_slot]["Info"]["magical"]):
			prefix = PlayerData.inv_data[inventory_slot]["Info"]["prefix"]
			suffix = PlayerData.inv_data[inventory_slot]["Info"]["suffix"]
	if (prefix != null):
		original_name = prefix + " " + original_name
	if (suffix != null):
		original_name = original_name + " " + suffix
	if (item_rarity == "Uncommon"):
		title_color = "83df65"
	elif (item_rarity == "Rare"):
		title_color = "123ce0"
	elif (item_rarity == "Epic"):
		title_color = "aa13cf"
	elif (item_rarity == "Legendary"):
		title_color = "daa812"
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/MarginContainer/Label").set("custom_colors/font_color", Color(title_color))
		
	var original_price = calculate_price(inventory_slot)
	npc_inventory_window.selected_item_price = original_price
	npc_inventory_window.selected_item_slot = inventory_slot
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/MarginContainer/Label").set_text(original_name)
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/HBoxContainer/TextureRect/Icon").set_texture(original_texture)
	npc_inventory_window.get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set_text(str(original_price) + " gold")

func _on_Icon_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_RIGHT:
				right_click(get_viewport().get_mouse_position())
			BUTTON_LEFT:
				left_click(get_viewport().get_mouse_position())