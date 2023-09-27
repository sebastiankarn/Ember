extends Control

var template_inv_slot = preload("res://Templates/NpcInventorySlot.tscn")
var regular_inv_slot = preload("res://Templates/SellInventorySlot.tscn")
var enchant_inv_slot = preload("res://Templates/EnchantInventorySlot.tscn")
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
	#HIDE CLASS NPC SETTINGS
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Buttons").show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop/NinjaText").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop/NinjaLabel").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop/KnightText").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop/KnightLabel").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer").show()
	
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
				var item_cost = ImportData.item_data[str(inventory[i]["Item"])]["Cost"]
				inv_slot_new.get_node("TextureRect/HBoxContainer/IconBackground/Icon").set_texture(icon_texture)
				if item_name != null:
					inv_slot_new.get_node("TextureRect/HBoxContainer/VBoxContainer/Name").set_text(item_name)
					inv_slot_new.get_node("TextureRect/HBoxContainer/VBoxContainer/Cost").set_text(str(item_cost) + " gold")
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
			var skill_tree_number = ImportData.skill_data[inventory[i]["Id"]].SkillTreeNode
			if skill_tree_number != null:
				if !player.get("skill_" + skill_tree_number):
					skill_slot_new.get_node("TextureRect/IconBackground/Icon").set_modulate(Color(0.4, 0.4, 0.4, 1))
			container.add_child(skill_slot_new, true)
	elif (npc_name == "Nellie"):
		open_enchantment_store()
	elif (npc_name == "Tosca"):
		open_knight_store()
	elif (npc_name == "Kylo"):
		open_ninja_store()
	update_gold(false)

func open_ninja_store():
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Buttons").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons").show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons/Accept").disabled = false
	if player.skill_Ninja:
		get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons/Accept").disabled = true
	if player.skill_Knight and PlayerData.player_stats["Level"] < 8:
		get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons/Accept").disabled = true
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop/NinjaText").show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop/NinjaLabel").show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer").hide()
	
func open_knight_store():
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Buttons").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons").show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons/Accept").disabled = false
	if player.skill_Knight:
		get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons/Accept").disabled = true
	if player.skill_Ninja and PlayerData.player_stats["Level"] < 8:
		get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons/Accept").disabled = true
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop/KnightText").show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer2/Shop/KnightLabel").show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer").hide()

	
func open_enchantment_store():
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").hide()
	_on_Inventory_pressed()
	enchant_button_node.show()
	buy_button_node.hide()
	sell_button_node.hide()
	shop_button_node.hide()
	inventory_button_node.hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/EnchantContainer").show()
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/RichTextLabel").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/EnchantContainer/Inv2/Texture").set_texture(null)
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/EnchantContainer/Inv3/Texture").set_texture(null)
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/EnchantContainer/Inv4/Texture").set_texture(null)
	for i in ImportData.npc_data["Nellie"]:
		ImportData.npc_data["Nellie"][i]["PlayerInvSlot"] = null
	enchant_button_node.disabled = true

func load_inventory(inventory):
	for i in gridcontainer.get_child_count():
		gridcontainer.remove_child(gridcontainer.get_child(0))
		
	for i in inventory.keys():
		var inv_slot_new
		if npc_name == 'Nellie':
			inv_slot_new = enchant_inv_slot.instance()
		else:
			inv_slot_new = regular_inv_slot.instance()
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
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Label2").hide()
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/HBoxContainer/TextureRect/Icon").set_texture(null)
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/RichTextLabel").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat1/Stat").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat2/Stat").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat3/Stat").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat4/Stat").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat5/Stat").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat6/Stat").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat7/Difference").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat1/Difference").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat2/Difference").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat3/Difference").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat4/Difference").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat5/Difference").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat6/Difference").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat7/Difference").set_text("")
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat7/Stat").set("custom_colors/font_color", Color("dddddd"))
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat1/Stat").set("custom_colors/font_color", Color("dddddd"))
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat2/Stat").set("custom_colors/font_color", Color("dddddd"))
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat3/Stat").set("custom_colors/font_color", Color("dddddd"))
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat4/Stat").set("custom_colors/font_color", Color("dddddd"))
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat5/Stat").set("custom_colors/font_color", Color("dddddd"))
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat6/Stat").set("custom_colors/font_color", Color("dddddd"))
	get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Stat7/Stat").set("custom_colors/font_color", Color("dddddd"))
	update_gold(false)
	

func _on_Inventory_pressed():
	shop_node.hide()
	inventory_node.show()
	sell_button_node.show()
	buy_button_node.hide()
	enchant_button_node.hide()
	reset_right_panel()
	

func buy_item(item_id):
	var inventory_full = true
	for inventory_item in PlayerData.inv_data.keys():
		if PlayerData.inv_data[inventory_item]["Item"] == null:
			inventory_full = false
	if inventory_full:
		print("BACKPACK IS FULL")
		return
	var stack
	var item_cost = ImportData.item_data[item_id]["Cost"]
	if (player.gold >= item_cost):
		player.gold -= item_cost
		if (ImportData.item_data[item_id]["Stackable"]):
			stack = 1
			player.loot_item(item_id, stack)
		else:
			player.loot_item(get_tree().get_current_scene().ItemGeneration(item_id, false), stack)
		update_gold(false)
		load_inventory(PlayerData.inv_data)

func update_gold(is_selling):
	if (str(selected_item_price) != '' && !is_selling):
		get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set_text("Cost: " + str(selected_item_price) + "/" + str(player.gold) + " gold")
		if selected_item_price > player.gold:
			get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set("custom_colors/font_color", Color("ff0000"))
		else:
			get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set("custom_colors/font_color", Color("83df65"))
	elif (str(selected_item_price) != ''):
		get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set_text("Worth: " + str(selected_item_price) + "/" + str(player.gold) + " gold")
		get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set("custom_colors/font_color", Color("dddddd"))
	else:
		get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set_text("Current gold: " + str(player.gold))
		get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/Price").set("custom_colors/font_color", Color("dddddd"))
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
		update_gold(true)

func enchant_item(inventory_slot):
	if inventory_slot == null:
		return
	PlayerData.inv_data[inventory_slot]["Stats"]["EnchantedLevel"] += 1
	var enchanted_inv_slot = gridcontainer.get_node(inventory_slot)
	var tween1 = enchanted_inv_slot.get_node("Icon/Tween")
	tween1.interpolate_property(enchanted_inv_slot, 'modulate', Color(2,2,2), Color(3,3,3), 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween1.interpolate_property(enchanted_inv_slot, 'modulate', Color(3,3,3), Color(1,1,1), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)
	tween1.start()
	
	#UPDATE ITEM STATS
	for i in PlayerData.inv_data[inventory_slot]["Stats"]:
		if ImportData.item_scaling_stats.has(i):
			if PlayerData.inv_data[inventory_slot]["Stats"][i] != null:
				#if typeof(PlayerData.inv_data[inventory_slot]["Stats"][i]) == 2:
				PlayerData.inv_data[inventory_slot]["Stats"][i] = int(PlayerData.inv_data[inventory_slot]["Stats"][i] * 1.2)
		
					
	#UPDATE ITEM INFO
	for i in PlayerData.inv_data[inventory_slot]["Info"]:
		if ImportData.item_scaling_stats.has(i):
			if PlayerData.inv_data[inventory_slot]["Info"][i] != null:
				#if typeof(PlayerData.inv_data[inventory_slot]["Info"][i]) == 2:
				PlayerData.inv_data[inventory_slot]["Info"][i] = int(PlayerData.inv_data[inventory_slot]["Info"][i] * 1.2)
			
	for i in ["Inv2", "Inv3", "Inv4"]:
		var player_inv_slot = gridcontainer.get_node(ImportData.npc_data["Nellie"][i]["PlayerInvSlot"])
		var tween = player_inv_slot.get_node("Icon/Tween")
		tween.interpolate_property(player_inv_slot, 'modulate', Color(0.5,0.5,0.5), Color(1,1,1), 0.1, Tween.TRANS_QUART, Tween.EASE_IN, 0.1)
		tween.start()
		sell_item(ImportData.npc_data["Nellie"][i]["PlayerInvSlot"], 0)
	open_enchantment_store()

func buy_skill(skill_id):
	var skill_cost = ImportData.skill_data[skill_id]["SkillCost"]
	var skill_tree_number = ImportData.skill_data[skill_id]["SkillTreeNode"]
	if skill_tree_number != null:
		if !player.get("skill_" + skill_tree_number):
			print("Need to unlock skill in skilltree")
			return
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
		update_gold(false)
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
			print(selected_item_id)
			buy_skill(selected_item_id)


func _on_Enchant_pressed():
	enchant_item(ImportData.npc_data["Nellie"]["Inv1"]["PlayerInvSlot"])


func _on_Accept_pressed():
	if (npc_name == 'Tosca'):
		player.skill_Knight = true
		get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons/Accept").disabled = true
	if (npc_name == 'Kylo'):
		player.skill_Ninja = true
		get_node("Background/M/V/HBoxContainer/VBoxContainer2/ClassButtons/Accept").disabled = true

func _on_Decline_pressed():
	self.hide()


#HUVUDRUTAN
func _on_TextureRect_gui_input(event):
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				BUTTON_RIGHT:
					var nellie_inventory = ImportData.npc_data["Nellie"]
					if nellie_inventory["Inv1"]["PlayerInvSlot"] != null:
						var player_inv_slot = gridcontainer.get_node(nellie_inventory["Inv1"]["PlayerInvSlot"])
						var tween = player_inv_slot.get_node("Icon/Tween")
						tween.interpolate_property(player_inv_slot, 'modulate', Color(2,2,2), Color(1,1,1), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)
						tween.start()
						nellie_inventory["Inv1"]["PlayerInvSlot"] = null
						reset_right_panel()

#FÖRSTA ENCHANTRUTAN
func _on_Inv2_gui_input(event):
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				BUTTON_RIGHT:
					var nellie_inventory = ImportData.npc_data["Nellie"]
					if nellie_inventory["Inv2"]["PlayerInvSlot"] != null:
						var nellie_slot_node = get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/EnchantContainer/Inv2/Texture")
						nellie_slot_node.set_texture(null)
						var player_inv_slot = gridcontainer.get_node(nellie_inventory["Inv2"]["PlayerInvSlot"])
						var tween = player_inv_slot.get_node("Icon/Tween")
						tween.interpolate_property(player_inv_slot, 'modulate', Color(0.5,0.5,0.5), Color(1,1,1), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)
						tween.start()
						nellie_inventory["Inv2"]["PlayerInvSlot"] = null

#ANDRA ENCHANTRUTAN
func _on_Inv3_gui_input(event):
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				BUTTON_RIGHT:
					var nellie_inventory = ImportData.npc_data["Nellie"]
					if nellie_inventory["Inv3"]["PlayerInvSlot"] != null:
						var nellie_slot_node = get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/EnchantContainer/Inv3/Texture")
						nellie_slot_node.set_texture(null)
						var player_inv_slot = gridcontainer.get_node(nellie_inventory["Inv3"]["PlayerInvSlot"])
						var tween = player_inv_slot.get_node("Icon/Tween")
						tween.interpolate_property(player_inv_slot, 'modulate', Color(0.5,0.5,0.5), Color(1,1,1), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)
						tween.start()
						nellie_inventory["Inv3"]["PlayerInvSlot"] = null

#TREDJE ENCHANTRUTAN
func _on_Inv4_gui_input(event):
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				BUTTON_RIGHT:
					var nellie_inventory = ImportData.npc_data["Nellie"]
					if nellie_inventory["Inv4"]["PlayerInvSlot"] != null:
						var nellie_slot_node = get_node("Background/M/V/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/EnchantContainer/Inv4/Texture")
						nellie_slot_node.set_texture(null)
						var player_inv_slot = gridcontainer.get_node(nellie_inventory["Inv4"]["PlayerInvSlot"])
						var tween = player_inv_slot.get_node("Icon/Tween")
						tween.interpolate_property(player_inv_slot, 'modulate', Color(0.5,0.5,0.5), Color(1,1,1), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)
						tween.start()
						nellie_inventory["Inv4"]["PlayerInvSlot"] = null
