extends TextureRect

func get_drag_data(_pos):
	var inv_slot = get_parent().get_name()
	if PlayerData.inv_data[inv_slot]["Item"] != null:
		var data = {}
		data["original_node"] = self
		data["original_panel"] = "Inventory"
		data["original_item_id"] = PlayerData.inv_data[inv_slot]["Item"]
		data["original_equipment_slot"] = ImportData.item_data[str(PlayerData.inv_data[inv_slot]["Item"])]["EquipmentSlot"]
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
	var target_inv_slot = get_parent().get_name()
	if PlayerData.inv_data[target_inv_slot]["Item"] == null:
		data["target_item_id"] = null
		data["target_texture"] = null
		return true
	else:
		data["target_item_id"] = PlayerData.inv_data[target_inv_slot]["Item"]
		data["target_texture"] = texture
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
	
	if data["original_panel"] == "Inventory":
		PlayerData.inv_data[original_slot]["Item"] = data["target_item_id"]
	else:
		PlayerData.equipment_data[original_slot] = data["target_item_id"]
		
	if data["original_panel"] == "CharacterSheet" and data["target_item_id"] == null:
		var default_texture = load("res://UI_elements/item_icons/" + original_slot + "_default_icon.webp")
		data["original_node"].texture = default_texture
	else:
		data["original_node"].texture = data["target_texture"]
		
	PlayerData.inv_data[target_inv_slot]["Item"] = data["original_item_id"]
	texture = data["original_texture"]
