extends Control

var template_loot_item = preload("res://Templates/LootIcon.tscn")
onready var player = get_node("/root/MainScene/Player")

func _ready():
	pass 

func fill_loot_list(loot_item, stack):
	var loot_item_new = template_loot_item.instance()
	if loot_item != null:
		var icon_texture
		if loot_item != "Gold":
			var item_name = ImportData.item_data[loot_item]["Name"]
			icon_texture = load("res://Sprites/Icon_Items/" + item_name + ".png")
		else:
			icon_texture = load("res://Sprites/Icon_Items/goldcoins.png")
		loot_item_new.get_node("Icon").set_texture(icon_texture)
		loot_item_new.get_node("Timer").wait_time = 5
		var item_stack = stack
		if item_stack != null and item_stack > 1:
			loot_item_new.get_node("Stack").set_text(str(item_stack))
	get_node("VBoxContainer").add_child(loot_item_new, true)
