extends Control

var template_inv_slot = preload("res://Templates/NpcInventorySlot.tscn")
var regular_inv_slot = preload("res://Templates/SellInventorySlot.tscn")
onready var player = get_node("/root/MainScene/Player")
onready var container = get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop/Scrollcontainer/VBoxContainer")
onready var inventory_node = get_node("Background/M/V/HBoxContainer/VBoxContainer2/Inventory")
onready var shop_node = get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop")
onready var sell_button_node = get_node("Background/M/V/HBoxContainer/VBoxContainer/Buttons/Sell")
onready var buy_button_node = get_node("Background/M/V/HBoxContainer/VBoxContainer/Buttons/Buy")
onready var enchant_button_node = get_node("Background/M/V/HBoxContainer/VBoxContainer/Buttons/Enchant")
onready var gridcontainer = get_node("Background/M/V/HBoxContainer/VBoxContainer2/Inventory/Scrollcontainer/Grid")
onready var player_inventory_grid = get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer")
onready var shop_button_node = get_node("Background/M/V/HBoxContainer/VBoxContainer2/Buttons/Shop")
onready var inventory_button_node = get_node("Background/M/V/HBoxContainer/VBoxContainer2/Buttons/Inventory")
onready var skill_panel_node = get_node("/root/MainScene/CanvasLayer/SkillPanel")
var template_skill_slot = preload("res://Templates/NpcSkillSlot.tscn")
var npc_name = ''
var selected_item_id = ''
var selected_item_slot = ''
var selected_item_price = ''

func _ready():
	pass

func load_shop(name):
	_on_Shop_pressed()
	shop_button_node.show()
	inventory_button_node.show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/EnchantContainer").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/RichTextLabel").hide()
	npc_name = name
	get_node("Background/M/V/Header/TitleBackground/Label").set_text(npc_name)
	get_node("Background/M/V/HBoxContainer/TextureRect").set_texture(load("res://UI_elements/NPC_images/" + npc_name + ".png"))
	for i in container.get_child_count():
		container.remove_child(container.get_child(0))
	if (npc_name == "Wictor"):
		var inventory = ImportData.npc_data[npc_name]
		for i in inventory.keys():	
			var inv_slot_new = template_inv_slot.instance()
			if inventory[i]["Item"] != null:
				var item_name = ImportData.item_data[str(inventory[i]["Item"])]["Name"]
				var icon_texture = load("res://Sprites/Icon_Items/" + item_name + ".png")
				inv_slot_new.get_node("TextureRect/IconBackground/Icon").set_texture(icon_texture)
				if item_name != null:
					inv_slot_new.get_node("TextureRect/Stack").set_text(item_name)
			container.add_child(inv_slot_new, true)
	elif (npc_name == "Gordon"):
		var inventory = ImportData.npc_data[npc_name]
		for i in inventory.keys():
			var skill_slot_new = template_skill_slot.instance()
			if inventory[i]["Id"] != null:
				var skill_name = ImportData.skill_data[inventory[i]["Id"]].SkillName
				var icon_texture = load("res://UI_elements/skill_icons/" + skill_name + ".png")
				skill_slot_new.get_node("TextureRect/IconBackground/Icon").set_texture(icon_texture)
				var skill_text = ImportData.skill_data[inventory[i]["Id"]]["SkillInfo"]
				if skill_text != null:
					skill_slot_new.get_node("TextureRect/Stack").set_text(skill_text)
			if (inventory[i]["Bought"]):
				skill_slot_new.hide()
			if (ImportData.skill_data[inventory[i]["Id"]].SkillLevel > PlayerData.player_stats["Level"]):
				skill_slot_new.get_node("TextureRect/IconBackground/Icon").set_modulate(Color(0.4, 0.4, 0.4, 1))
			container.add_child(skill_slot_new, true)
	elif (npc_name == "Nellie"):
		open_enchantment_store()
	update_gold()

func open_enchantment_store():
	_on_Inventory_pressed()
	enchant_button_node.show()
	buy_button_node.hide()
	sell_button_node.hide()
	shop_button_node.hide()
	inventory_button_node.hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/EnchantContainer").show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/RichTextLabel").hide()

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
	enchant_button_node.hide()
	reset_right_panel()
	
func reset_right_panel():
	selected_item_id = ''
	selected_item_price = ''
	selected_item_slot = ''
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label2").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/HBoxContainer/TextureRect/Icon").set_texture(null)
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/RichTextLabel").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set_text("")
	

func _on_Inventory_pressed():
	shop_node.hide()
	inventory_node.show()
	sell_button_node.show()
	buy_button_node.hide()
	enchant_button_node.hide()
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

func enchant_item(inventory_slot):
	pass

func buy_skill(skill_id):
	var skill_cost = ImportData.skill_data[skill_id]["SkillCost"]
	if (ImportData.skill_data[skill_id].SkillLevel > PlayerData.player_stats["Level"]):
		print("Not high level enough")
	elif (player.gold >= skill_cost):
		player.gold -= skill_cost
		var first_available_skill_slot
		for i in PlayerData.skills_data.keys():
			if (PlayerData.skills_data[i]["Id"] == null):
				if (first_available_skill_slot == null):
					first_available_skill_slot = i
			if (PlayerData.skills_data[i]["Id"] == skill_id):
				return
		PlayerData.skills_data[first_available_skill_slot]["Id"] = skill_id
		var npc_inventory = ImportData.npc_data[npc_name]
		for i in npc_inventory.keys():
			if (npc_inventory[i]["Id"] == skill_id):
				npc_inventory[i]["Bought"] = true
		skill_panel_node.reload_skills()
		update_gold()
		load_shop(npc_name)
	else:
		print("Not enough cash")

func _on_Sell_pressed():
	if (selected_item_id != ''):
		sell_item(selected_item_slot, selected_item_price)


func _on_Buy_pressed():
	if(selected_item_id != ''):
		if (npc_name == 'Wictor'):
			buy_item(selected_item_id)
		elif (npc_name == 'Gordon'):
			buy_skill(selected_item_id)


func _on_Enchant_pressed():
	if (selected_item_id != ''):
		 enchant_item(selected_item_id)
