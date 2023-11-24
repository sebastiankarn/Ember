extends Control

@onready var item_texture = get_node("NinePatchRect/VBoxContainer/VBoxContainer/HBoxContainer/TextureRect/ItemRect")
@onready var progress_bar1 = get_node("NinePatchRect/VBoxContainer/VBoxContainer/HBoxContainer/TextureProgress4")
@onready var progress_bar2 = get_node("NinePatchRect/VBoxContainer/VBoxContainer/HBoxContainer/TextureProgress3")
@onready var tween1 = get_node("NinePatchRect/VBoxContainer/VBoxContainer/HBoxContainer/TextureProgress4/Tween")
@onready var tween2 = get_node("NinePatchRect/VBoxContainer/VBoxContainer/HBoxContainer/TextureProgress3/Tween")
@onready var success_rate_label = get_node("NinePatchRect/VBoxContainer/NinePatchRect3/VBoxContainer/Label")
@onready var label = get_node("NinePatchRect/VBoxContainer/NinePatchRect3/Label")
@onready var confirm_button = get_node("NinePatchRect/VBoxContainer/NinePatchRect2/Buttons/Confirm")
@onready var button_margin = get_node("NinePatchRect/VBoxContainer/NinePatchRect2/Buttons/MarginContainer")
var inventory_slot
var imported_item_texture

func _ready():
	var enchant_level = PlayerData.inv_data[inventory_slot]["Stats"]["EnchantedLevel"]
	var success_rate = get_parent().get_success_rate(enchant_level)
	item_texture.set_texture(imported_item_texture)
	var original_success_rate_label = success_rate_label.get_text()
	success_rate_label.set_text(original_success_rate_label + str(success_rate * 100) + "%")
	

func _on_Confirm_button_up():
	tween1.interpolate_property(progress_bar1, 'value', 0, 100, 1)
	tween2.interpolate_property(progress_bar2, 'value', 0, 100, 1)
	tween1.start()
	tween2.start()
	await get_tree().create_timer(1).timeout
	var success = get_parent().enchant_item(inventory_slot)
	confirm_button.hide()
	button_margin.hide()
	if success:
		on_success()
	else:
		on_failure()
	
func on_success():
	get_node("NinePatchRect/VBoxContainer/NinePatchRect3/VBoxContainer").hide()
	label.set_text("Enchantment succeeded!")
	label.set("theme_override_colors/font_color", Color("3eff00"))
	label.show()
	tween1.interpolate_property(get_node("NinePatchRect/VBoxContainer/VBoxContainer/HBoxContainer/TextureRect"), 'modulate', Color(1,1,1), Color(3,3,3), 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween1.interpolate_property(get_node("NinePatchRect/VBoxContainer/VBoxContainer/HBoxContainer/TextureRect"), 'modulate', Color(3,3,3), Color(1,1,1), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)
	tween2.interpolate_property(item_texture, 'scale', Vector2(1, 1), Vector2(2.2, 2.2), 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween2.interpolate_property(item_texture, 'scale', Vector2(2.2, 2.2), Vector2(1, 1), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)
	tween1.start()
	tween2.start()
	

func on_failure():
	get_node("NinePatchRect/VBoxContainer/NinePatchRect3/VBoxContainer").hide()
	label.set_text("Enchantment failed!")
	label.set("theme_override_colors/font_color", Color("ff0000"))
	label.show()
	tween1.interpolate_property(get_node("NinePatchRect/VBoxContainer/VBoxContainer/HBoxContainer/TextureRect"), 'modulate', Color(1,1,1), Color(0.5,0.5,0.5), 0.6, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween1.interpolate_property(item_texture, 'modulate', Color(1,1,1), Color(0,0,0), 0.6, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween2.interpolate_property(item_texture, 'scale', Vector2(1, 1), Vector2(0.7, 0.7), 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween2.interpolate_property(item_texture, 'scale', Vector2(0.7, 0.7), Vector2(1, 1), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)

func _on_Cancel_button_up():
	queue_free()


func _on_Exit_button_up():
	queue_free()
