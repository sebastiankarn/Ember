extends NinePatchRect
var character_id
@onready var character_name_node = $TextureRect/VBoxContainer/CharacterName
@onready var character_info_node = $TextureRect/VBoxContainer/Info
@onready var character_select_node = get_node("/root/CharacterSelect")
var character_name
var character_info

func _ready():
	if character_name:
		character_name_node.text = character_name
	if character_info:
		character_info_node.text = character_info

func reset_node():
	var tween = create_tween()
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
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.5,0.5,0.5), 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				click_character()
