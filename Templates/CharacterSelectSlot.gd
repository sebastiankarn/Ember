extends NinePatchRect
var character_id
var sprite_path = "res://Sprites"
var items_path = "res://Sprites/Icon_Items"
@onready var character_name_node = $TextureRect/VBoxContainer/CharacterName
@onready var character_info_node = $TextureRect/VBoxContainer/Info
@onready var character_icon_node = $TextureRect/IconBackground/Icon
@onready var character_select_node = get_node("/root/CharacterSelect")
var character_name
var character_info

func _ready():
	if character_name:
		character_name_node.text = character_name
	if character_info:
		character_info_node.text = character_info
		if character_info.contains("Hunter"):
			character_icon_node.texture = load(items_path + "/Bow.png")
		elif character_info.contains("Knight"):
			character_icon_node.texture = load(items_path + "/Plate Helmet.png")
		elif character_info.contains("Ninja"):
			character_icon_node.texture = load(items_path + "/Vengeance.png")
		else:
			character_icon_node.texture = load(items_path + "/Mana Potion.png")

func reset_node():
	var tween = create_tween()
	if tween != null:
		tween.tween_property(self, "modulate", Color(1,1,1), 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)

func click_character():
	if character_select_node.selected_character_node == self:
		return
	if character_id:
		if character_select_node.selected_character_node:
			character_select_node.selected_character_node.reset_node()
		character_select_node.selected_character_node = self
	else:
		print("Couldn't find character id!!!")
	
	character_select_node.character_name_label.text = character_name
	if character_info.contains("Hunter"):
		character_select_node.character_texture.texture = load(sprite_path + "/hunter.png")
	elif character_info.contains("Knight"):
		character_select_node.character_texture.texture = load(sprite_path + "/knight.png")
	elif character_info.contains("Ninja"):
		character_select_node.character_texture.texture = load(sprite_path + "/ninja.png")
	else:
		character_select_node.character_texture.texture = load(sprite_path + "/enchanter.png")
	character_select_node.delete_button.show()
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.5,0.5,0.5), 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				click_character()
