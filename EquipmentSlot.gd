extends TextureRect

onready var tool_tip = preload("res://Templates/ToolTip.tscn")

func _ready():
	connect("mouse_entered", self, "_on_Icon_mouse_entered")
	connect("mouse_exited", self, "_on_Icon_mouse_exited")

func get_drag_data(_pos):
	var equipment_slot = get_parent().get_name()
	if PlayerData.equipment_data[equipment_slot] != null:
		var data = {}
		data["original_node"] = self
		data["original_panel"] = "CharacterSheet"
		data["original_item_id"] = PlayerData.equipment_data[equipment_slot]
		data["original_equipment_slot"] = equipment_slot
		data["original_stackable"] = false
		data["original_stack"] = 1
		data["original_texture"] = texture
		
	
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = texture
		drag_texture.rect_size = Vector2(100, 100)
		
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)
		
		return data
	
func can_drop_data(_pos, data):
	var target_equipment_slot = get_parent().get_name()
	if target_equipment_slot == data["original_equipment_slot"]:
		if PlayerData.equipment_data[target_equipment_slot] == null:
			data["target_item_id"] = null
			data["target_texture"] = null
		else:
			data["target_item_id"] = PlayerData.equipment_data[target_equipment_slot]
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
		PlayerData.equipment_data[original_slot] = data["target_item_id"]
		
	if data["original_panel"] == "CharacterSheet" and data["target_item_id"] == null:
		var default_texture = load("res://UI_elements/item_icons/" + original_slot + "_default_icon.webp")
		data["original_node"].texture = default_texture
	else:
		data["original_node"].texture = data["target_texture"]
		
	PlayerData.equipment_data[target_equipment_slot] = data["original_item_id"]
	texture = data["original_texture"]

func _on_Icon_mouse_entered():
	var tool_tip_instance = tool_tip.instance()
	tool_tip_instance.origin = "CharacterSheet"
	tool_tip_instance.slot = get_parent().get_name()
	
	tool_tip_instance.rect_position = get_parent().get_global_transform_with_canvas().origin + Vector2(100, 0)

	add_child(tool_tip_instance)
	yield(get_tree().create_timer(0.35), "timeout")
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()
		

func _on_Icon_mouse_exited():
	get_node("ToolTip").free()
