extends Control
var data

func _on_Exit_button_up():
	queue_free()


func _on_Cancel_button_up():
	queue_free()


func _on_Confirm_button_up():
	var item_slot = data["original_node"].get_parent().get_name()
	var picked_item = data["original_item_id"] 
	var current_item = PlayerData.inv_data[item_slot]["Item"]
	if (current_item == picked_item):
		get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/NinePatchRect/HBoxContainer/RemoveRect").remove_item(item_slot)
		queue_free()
	else:
		var label = get_node("NinePatchRect/VBoxContainer/VBoxContainer/Label")
		label.set_text("COULD NOT REMOVE ITEM")
		var confirm_button = get_node("NinePatchRect/VBoxContainer/NinePatchRect2/Buttons/Confirm")
		var button_margin = get_node("NinePatchRect/VBoxContainer/NinePatchRect2/Buttons/MarginContainer")
		var cancel_label = get_node("NinePatchRect/VBoxContainer/NinePatchRect2/Buttons/Cancel/Label")
		confirm_button.hide()
		button_margin.hide()
		cancel_label.set_text("Close")
		
