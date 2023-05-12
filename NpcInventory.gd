extends Control

var template_inv_slot = preload("res://Templates/NpcInventorySlot.tscn")
var regular_inv_slot = preload("res://Templates/SellInventorySlot.tscn")
onready var player = get_node("/root/MainScene/Player")
onready var container = get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop/Scrollcontainer/VBoxContainer")
onready var inventory_node = get_node("Background/M/V/HBoxContainer/VBoxContainer2/Inventory")
onready var shop_node = get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop")
onready var sell_button_node = get_node("Background/M/V/HBoxContainer/VBoxContainer/Buttons/Sell")
onready var buy_button_node = get_node("Background/M/V/HBoxContainer/VBoxContainer/Buttons/Buy")
onready var gridcontainer = get_node("Background/M/V/HBoxContainer/VBoxContainer2/Inventory/Scrollcontainer/Grid")
onready var player_inventory_grid = get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer")
var template_skill_slot = preload("res://Templates/SkillPanelSlot.tscn")
var npc_name = ''
var selected_item_id = ''
var selected_item_slot = ''
var selected_item_price = ''

func _ready():
	pass

func load_shop(name):
	npc_name = name
	get_node("Background/M/V/Header/TitleBackground/Label").set_text(npc_name)
	var inventory = ImportData.npc_data[npc_name]
	for i in container.get_child_count():
		container.remove_child(container.get_child(0))
	if (npc_name == "Gordon"):
		for i in inventory.keys():	
			var inv_slot_new = template_inv_slot.instance()
			if inventory[i]["Item"] != null:
				var item_name = ImportData.item_data[str(inventory[i]["Item"])]["Name"]
				var icon_texture = load("res://Sprites/Icon_Items/" + item_name + ".png")
				inv_slot_new.get_node("TextureRect/IconBackground/Icon").set_texture(icon_texture)
				if item_name != null:
					inv_slot_new.get_node("TextureRect/Stack").set_text(item_name)
			container.add_child(inv_slot_new, true)
	elif (npc_name == "Wictor"):
		for i in inventory.keys():
			var skill_slot_new = template_skill_slot.instance()
			if inventory[i]["Id"] != null:
				var skill_name = ImportData.skill_data[inventory[i]["Id"]].SkillName
				var icon_texture = load("res://UI_elements/skill_icons/" + skill_name + ".png")
				skill_slot_new.get_node("TextureRect/IconBackground/Icon").set_texture(icon_texture)
				var skill_text = ImportData.skill_data[inventory[i]["Id"]]["SkillInfo"]
				if skill_text != null:
					skill_slot_new.get_node("TextureRect/Stack").set_text(skill_text)
			container.add_child(skill_slot_new, true)
	update_gold()

func load_inventory(inventory):
	for i in gridcontainer.get_child_count():
		gridcontainer.remove_child(gridcontainer.get_child(0))
	for i in inventory.keys():
		var inv_slot_new = regular_inv_slot.instance()
		if PlayerData.inv_data[i]["Item"] != null:
			var item_name = ImportData.item_data[str(PlayerData.inv_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Sprites/Icon_Items/" + item_name + ".png")
			inv_slot_new.get_node("Icon").set_texture(icon_texture)
			inv_slot_new.get_node("Icon/Sweep").texture_progress = icon_texture
			inv_slot_new.get_node("Icon/Sweep/Timer").wait_time = 20
			inv_slot_new.get_node("Icon/Sweep").value = 0
			var item_stack = PlayerData.inv_data[i]["Stack"]
			if item_stack != null and item_stack > 1:
				inv_slot_new.get_node("Stack").set_text(str(item_stack))
		gridcontainer.add_child(inv_slot_new, true)

func get_name():
	return npc_name

func _on_Button_pressed():
	self.hide()


func _on_Shop_pressed():
	shop_node.show()
	inventory_node.hide()
	sell_button_node.hide()
	buy_button_node.show()
	reset_right_panel()
	
func reset_right_panel():
	selected_item_id = ''
	selected_item_price = ''
	selected_item_slot = ''
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/MarginContainer/Label").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/HBoxContainer/TextureRect/Icon").set_texture(null)
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/RichTextLabel").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set_text("")
	

func _on_Inventory_pressed():
	shop_node.hide()
	inventory_node.show()
	sell_button_node.show()
	buy_button_node.hide()
	reset_right_panel()
	

func buy_item(item_id):
	var stack
	var item_cost = ImportData.item_data[item_id]["Cost"]
	if (player.gold >= item_cost):
		player.gold -= item_cost
		if (ImportData.item_data[item_id]["Stackable"]):
			stack = 1
			player.loot_item(item_id, stack)
		else:
			player.loot_item(get_tree().get_current_scene().ItemGeneration(item_id), stack)
		update_gold()
		load_inventory(PlayerData.inv_data)

func update_gold():
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Gold").set_text("Current gold: " + str(player.gold))
	get_node("/root/MainScene/CanvasLayer/Inventory").update_inventory_gold()

func sell_item(inventory_slot, cost):
	if (PlayerData.inv_data[inventory_slot] != null):
		var stack = PlayerData.inv_data[inventory_slot]["Stack"]
		print(stack)
		if stack > 2:
			PlayerData.inv_data[inventory_slot]["Stack"] -= 1
			player_inventory_grid.get_node(inventory_slot + "/Stack").set_text(str(stack - 1))
			gridcontainer.get_node(inventory_slot + "/Stack").set_text(str(stack - 1))
		elif stack == 2:
			PlayerData.inv_data[inventory_slot]["Stack"] -= 1
			player_inventory_grid.get_node(inventory_slot + "/Stack").set_text("")
			gridcontainer.get_node(inventory_slot + "/Stack").set_text("")
		else:
			PlayerData.inv_data[inventory_slot]["Item"] = null
			PlayerData.inv_data[inventory_slot]["Stack"] = null
			gridcontainer.get_node(inventory_slot + "/Icon").texture = null
			gridcontainer.get_node(inventory_slot + "/Icon/Sweep").texture_progress = null
			gridcontainer.get_node(inventory_slot + "/Icon/Sweep/Timer").wait_time = 0
			player_inventory_grid.get_node(inventory_slot + "/Icon").texture = null
			player_inventory_grid.get_node(inventory_slot + "/Icon/Sweep").texture_progress = null
			player_inventory_grid.get_node(inventory_slot + "/Icon/Sweep/Timer").wait_time = 0
			reset_right_panel()
		
		player.gold += cost
		update_gold()

func _on_Sell_pressed():
	if (selected_item_id != ''):
		sell_item(selected_item_slot, selected_item_price)


func _on_Buy_pressed():
	if(selected_item_id != ''):
		buy_item(selected_item_id)
