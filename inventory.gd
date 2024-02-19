extends Control

var template_inv_slot = preload("res://Templates/InventorySlot.tscn")

@onready var gridcontainer = get_node("Background/M/V/ScrollContainer/GridContainer")
@onready var current_gold = get_node("Background/M/V/NinePatchRect/HBoxContainer/Gold")
@onready var player = get_node("/root/MainScene/Player")

func _ready():
	reload_inventory()

func reload_inventory():
	for i in gridcontainer.get_child_count():
		gridcontainer.remove_child(gridcontainer.get_child(0))
	for i in PlayerData.inv_data.keys():
		var inv_slot_new = template_inv_slot.instantiate()
		if PlayerData.inv_data[i]["Item"] != null:
			var item_name = ImportData.item_data[str(PlayerData.inv_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Sprites/Icon_Items/" + item_name + ".png")
			inv_slot_new.get_node("Icon").set_texture(icon_texture)
			inv_slot_new.get_node("Icon/Sweep").texture_progress = load("res://UI_elements/UI_Square.png")#icon_texture
			inv_slot_new.get_node("Icon/Sweep/Timer").wait_time = 20
			inv_slot_new.get_node("Icon/Sweep").value = 0
			var item_stack = PlayerData.inv_data[i]["Stack"]
			if item_stack != null and item_stack > 1:
				inv_slot_new.get_node("Stack").set_text(str(item_stack))
		gridcontainer.add_child(inv_slot_new, true)
	update_inventory_gold()
	
func update_inventory_gold():
	current_gold.set_text(str(player.gold))

func _on_Button_pressed():
	self.hide()
