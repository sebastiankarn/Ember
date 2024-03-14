extends TextureRect

func _can_drop_data(_pos, data):
	if data["original_item_id"] != null:
		return true
	else:
		return false

func _drop_data(_pos, data):
	open_remove_item_window(data)

func open_remove_item_window(data):
	var confirm_remove_window = get_node_or_null("/root/MainScene/CanvasLayer/Inventory/ConfirmRemoveWindow")
	if confirm_remove_window != null:
		confirm_remove_window.queue_free()
	confirm_remove_window = load("res://ConfirmRemoveWindow.tscn")
	var window_instance = confirm_remove_window.instantiate()
	window_instance.data = data
	get_node("/root/MainScene/CanvasLayer/Inventory").add_child(window_instance)

func remove_item(item_slot):
	get_node("/root/MainScene/CanvasLayer/NpcInventory").sell_item(item_slot, 0)
