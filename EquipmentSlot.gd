extends TextureRect

onready var tool_tip = preload("res://Templates/ToolTip.tscn")
onready var canvas_layer = get_node("/root/MainScene/CanvasLayer")

func _ready():
	connect("mouse_entered", self, "_on_Icon_mouse_entered")
	connect("mouse_exited", self, "_on_Icon_mouse_exited")
	connect("gui_input", self, "_on_Icon_gui_input")
	
func unequip_click(_pos):
	var equipment_slot = get_parent().get_name()
	var data = {}
	if PlayerData.equipment_data[equipment_slot]["Item"] != null:
		data["original_node"] = self
		data["original_panel"] = "CharacterSheet"
		data["original_item_id"] = PlayerData.equipment_data[equipment_slot]["Item"]
		data["original_stats"] = PlayerData.equipment_data[equipment_slot]["Stats"]
		data["original_info"] = PlayerData.equipment_data[equipment_slot]["Info"]
		data["original_equipment_slot"] = equipment_slot
		data["original_stackable"] = false
		data["original_stack"] = 1
		data["original_texture"] = texture
	else:
		#Har ingenting equippat
		return
		
	var target_inv_slot
	for inventory_slot in PlayerData.inv_data:
		if PlayerData.inv_data[inventory_slot]["Item"] == null:
			target_inv_slot = inventory_slot
			break
	
	if target_inv_slot != null:
		PlayerData.ChangeEquipment(equipment_slot, null, null, null)
		var default_texture = load("res://UI_elements/item_icons/" + equipment_slot + "_default_icon.webp")
		data["original_node"].texture = default_texture
		PlayerData.inv_data[target_inv_slot]["Item"] = data["original_item_id"]
		PlayerData.inv_data[target_inv_slot]["Stats"] = data["original_stats"]
		PlayerData.inv_data[target_inv_slot]["Info"] = data["original_info"]
		var inv_node = get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer/" + target_inv_slot + "/Icon")
		var inv_stack_node = get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer/" + target_inv_slot + "/Stack")
		inv_node.texture = data["original_texture"]
		PlayerData.inv_data[target_inv_slot]["Stack"] = data["original_stack"]
		inv_stack_node.set_text("")
		canvas_layer.LoadShortCuts()
	else:
		print("BACKPACK IS FULL")
	
func get_drag_data(_pos):
	var equipment_slot = get_parent().get_name()
	if PlayerData.equipment_data[equipment_slot]["Item"] != null:
		var data = {}
		data["original_node"] = self
		data["original_panel"] = "CharacterSheet"
		data["original_item_id"] = PlayerData.equipment_data[equipment_slot]["Item"]
		data["original_stats"] = PlayerData.equipment_data[equipment_slot]["Stats"]
		data["original_info"] = PlayerData.equipment_data[equipment_slot]["Info"]
		data["original_equipment_slot"] = equipment_slot
		data["original_stackable"] = false
		data["original_stack"] = 1
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
	if data["original_panel"] == "SkillPanel":
		return false
	var target_equipment_slot = get_parent().get_name()
	if target_equipment_slot == data["original_equipment_slot"]:
		if PlayerData.equipment_data[target_equipment_slot]["Item"] == null:
			data["target_item_id"] = null
			data["target_texture"] = null
		else:
			data["target_item_id"] = PlayerData.equipment_data[target_equipment_slot]["Item"]
			data["target_stats"] = PlayerData.equipment_data[target_equipment_slot]["Stats"]
			data["target_info"] = PlayerData.equipment_data[target_equipment_slot]["Info"]
			data["target_texture"] = texture
		return true
	else:
		return false
	
func drop_data(_pos, data):
	var target_equipment_slot = get_parent().get_name()
	var original_slot = data["original_node"].get_parent().get_name()
	
	if data["original_panel"] == "Inventory":
		PlayerData.inv_data[original_slot]["Item"] = data["target_item_id"]
	else:
		PlayerData.ChangeEquipment(target_equipment_slot, data["original_item_id"], data["original_stats"], data["original_info"])
		
	if data["original_panel"] == "CharacterSheet" and data["target_item_id"] == null:
		var default_texture = load("res://UI_elements/item_icons/" + original_slot + "_default_icon.webp")
		data["original_node"].texture = default_texture
	else:
		data["original_node"].texture = data["target_texture"]
		
	PlayerData.ChangeEquipment(target_equipment_slot, data["original_item_id"], data["original_stats"], data["original_info"])
	texture = data["original_texture"]
	canvas_layer.LoadShortCuts()



func _on_Icon_mouse_entered():
	var tool_tip_instance = tool_tip.instance()
	tool_tip_instance.origin = "CharacterSheet"
	tool_tip_instance.slot = get_parent().get_name()
	
	tool_tip_instance.rect_position = get_parent().get_global_transform_with_canvas().origin + Vector2(50, 0)

	add_child(tool_tip_instance)
	yield(get_tree().create_timer(0.35), "timeout")
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()
		

func _on_Icon_mouse_exited():
	get_node("ToolTip").free()

func _on_Icon_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_RIGHT:
				unequip_click(get_viewport().get_mouse_position())
