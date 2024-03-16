extends Node2D

@onready var player = get_node("/root/MainScene/Player")
@onready var character_sheet = $CanvasLayer/CharacterSheet
@onready var inventory = $CanvasLayer/Inventory
@onready var skill_bar = $CanvasLayer/SkillBar
@onready var skill_panel = $CanvasLayer/SkillPanel
@onready var cast_bar = $CanvasLayer/CastBar
@onready var settings_window = $CanvasLayer/SettingsWindow
@onready var quest_log = $CanvasLayer/QuestLog

var map_current_level = 2
var map_maximum_level = 80

func _ready():
	for item_slot in get_tree().get_nodes_in_group("item_slot"):
		var index = item_slot.get_index()
		item_slot.connect("gui_input", Callable(self, "_on_ItemSlot_gui_input").bind(index))
		item_slot.connect("mouse_entered", Callable(self, "show_tooltip").bind(index))
		item_slot.connect("mouse_exited", Callable(self, "hide_tooltip"))
	load_game()
	

func check_first_login():
	
	return true

func _unhandled_input(event):
	if event.is_action_pressed("ui_character_sheet"):
		press_character_sheet()
	if event.is_action_pressed("ui_inventory"):
		press_inventory()
	if event.is_action_pressed("ui_skill_panel"):
		press_skills()
	if event.is_action_pressed("ui_quest_log"):
		press_quest_log()
	if event.is_action_pressed("ui_cancel"):
		var ui_hidden = check_if_ui_hidden()
		if ui_hidden:
			press_settings()
		else:
			hide_all_ui()

func press_character_sheet():
	character_sheet.visible = !character_sheet.visible
	hide_tooltips(character_sheet)
	character_sheet.LoadSkills()
	character_sheet.LoadStats()

func press_inventory():
	inventory.visible = !inventory.visible
	hide_tooltips(inventory)

func press_skills():
	skill_panel.visible = !skill_panel.visible
	hide_tooltips(skill_panel)

func press_quest_log():
	quest_log.reset_quest_log()
	player.checkAvailableQuests()
	quest_log.visible = !quest_log.visible
	hide_tooltips(quest_log)

func press_settings():
	settings_window.visible = !settings_window.visible

func check_if_ui_hidden():
	if skill_panel.visible or inventory.visible or character_sheet.visible or $CanvasLayer/NpcInventory.visible or $CanvasLayer/EnemyUI.visible or $CanvasLayer/NpcQuestWindow.visible or settings_window.visible or quest_log.visible:
		return false
	else:
		return true

func hide_all_ui():
	skill_panel.hide()
	hide_tooltips(skill_panel)
	inventory.hide()
	hide_tooltips(inventory)
	character_sheet.hide()
	hide_tooltips(character_sheet)
	$CanvasLayer/NpcInventory.hide()
	$CanvasLayer/NpcQuestWindow.hide()
	settings_window.hide()
	quest_log.hide()
	$CanvasLayer/EnemyUI.hide()
	
func hide_tooltips(node):
	for N in node.get_children():
		if N.get_name() == "ToolTip":
			N.free()
		elif N.get_child_count() > 0:
			hide_tooltips(N)
		else:
			pass

func ItemGeneration(item_id, is_loot):
	var new_item = {}
	if item_id != null:
		new_item["item_id"] = str(item_id)
	else:
		new_item["item_id"] = ItemDetermineType()
	if is_loot:
		new_item["item_rarity"] = ItemDetermineRarity()
		new_item["magical"] = ItemDetermineMagical(new_item["item_rarity"])
	else:
		new_item["item_rarity"] = "Common"
		new_item["magical"] = false
	if new_item["magical"]:
		new_item["prefix"] = ItemDeterminePrefix(new_item["item_id"])
		new_item["suffix"] = ItemDetermineSuffix(new_item["item_id"])
		if new_item["prefix"] == null and new_item["suffix"] == null:
			new_item["magical"] = false
			new_item.erase("prefix")
			new_item.erase("suffix")
		else:
			if new_item["prefix"]:
				new_item[new_item["prefix"]] = ItemDetermineMagicalStat(new_item["prefix"])
			if new_item["suffix"]:
				new_item[new_item["suffix"]] = ItemDetermineMagicalStat(new_item["suffix"])
			
	for i in ImportData.item_stats:
		if ImportData.item_data[new_item["item_id"]][i] != null:
			new_item[i] = ItemDetermineStats(new_item["item_id"], new_item["item_rarity"], i)
	return new_item
	
func ItemDetermineType():
	var new_item_type
	var item_types = ImportData.item_data.keys()
	randomize()
	new_item_type = item_types[randi() % item_types.size()]
	return new_item_type

func ItemDetermineRarity():
	var new_item_rarity
	var item_rarities = ImportData.item_rarity_distribution.keys()
	randomize()
	var rarity_roll = randi() % 100 + 1
	for i in item_rarities:
		if rarity_roll <= ImportData.item_rarity_distribution[i]:
			new_item_rarity = i
			break
		else:
			rarity_roll -= ImportData.item_rarity_distribution[i]
	return new_item_rarity
		
func ItemDetermineMagical(new_item_rarity):
	var new_item_magical
	randomize()
	var magical_roll = randi() % 100 + 1
	if magical_roll <= ImportData.item_magical_chance[new_item_rarity]:
		new_item_magical = true
	else:
		new_item_magical = false
	return new_item_magical
	
		
func ItemDeterminePrefix(item_id):
	var new_item_prefix
	randomize()
	var prefix_roll = randi() % 100 + 1
	if prefix_roll >= 50:
		var prefix_pool = []
		for prefix in ImportData.item_magical_prefixes:
			if ImportData.item_data[item_id][prefix]:
				prefix_pool.append(prefix)
		new_item_prefix = prefix_pool[randi() % prefix_pool.size()]
	else:
		new_item_prefix = null
	return new_item_prefix
		
		
func ItemDetermineSuffix(item_id):
	var new_item_suffix
	randomize()
	var suffix_roll = randi() % 100 + 1
	if suffix_roll >= 50:
		var suffix_pool = []
		for suffix in ImportData.item_magical_suffixes:
			if ImportData.item_data[item_id][suffix]:
				suffix_pool.append(suffix)
		new_item_suffix = suffix_pool[randi() % suffix_pool.size()]
	else:
		new_item_suffix = null
	return new_item_suffix
		
func ItemDetermineMagicalStat(magical_property):
	var magical_stat_value
	var min_stat_value = ImportData.magical_properties_data[magical_property]["MagicalStatMin"]
	var max_stat_value = ImportData.magical_properties_data[magical_property]["MagicalStatMax"]
	var map_modifier = float(map_current_level) / float(map_maximum_level)
	var min_stat = clamp((((max_stat_value - min_stat_value) * map_modifier) + min_stat_value) * 0.8, min_stat_value, max_stat_value)
	var max_stat = clamp((((max_stat_value - min_stat_value) * map_modifier) + min_stat_value) * 1.2, min_stat_value, max_stat_value)
	randomize()
	magical_stat_value = (randf_range(min_stat, max_stat))
	return magical_stat_value
	
func ItemDetermineStats(item_id, rarity, stat):
	var stat_value
	if ImportData.item_scaling_stats.has(stat):
		stat_value = ImportData.item_data[item_id][stat] * ImportData.item_data[item_id][rarity + "Multi"]
	else:
		stat_value = ImportData.item_data[item_id][stat]
	return stat_value

func save_game():
	var saved_game:SavedGame = SavedGame.new()

	saved_game.map_current_level = map_current_level
	saved_game.map_maximum_level = map_maximum_level
	saved_game.lightOn = !(get_node("CanvasModulate").visible)
	saved_game.player_data = player.on_save_game()
	var saved_data:Array[SavedData] = []
	get_tree().call_group("game_events", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	
	ResourceSaver.save(saved_game, "user://savegame" + PlayerData.user_name + str(PlayerData.character_id) + ".tres")

func load_game():
	var file_path = "user://savegame" + PlayerData.user_name + str(PlayerData.character_id) + ".tres"
	if !FileAccess.file_exists(file_path):
		return
	var saved_game:SavedGame = load(file_path) as SavedGame
	if saved_game == null:
		return
	if saved_game.player_data.player_stats.is_empty():
		player.load_new_character_data(saved_game.player_data)
		return
	map_current_level = saved_game.map_current_level
	map_maximum_level = saved_game.map_maximum_level
	
	#HANDLE PLAYER, UI
	player.on_load_game(saved_game.player_data)

	#HANDLE ITEMS/MOBS/BOSSES/ENVIRONMENT
	get_tree().call_group("game_events", "on_before_load_game")
	var saved_data = saved_game.saved_data
	for item in saved_data:
		var scene = load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		add_child(restored_node)
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)
	
	#HANDLE LIGHTS, NEEDS TO WAIT A SECOND TO LOAD CORRECTLY
	await get_tree().create_timer(0.5).timeout
	if saved_game.lightOn:
		turn_on_light()
	else:
		turn_off_light()
	var loading_scenes = get_tree().get_nodes_in_group("LoadingScreen")
	for loading_scene in loading_scenes:
		if loading_scene.has_method("main_scene_loaded"):
			loading_scene.main_scene_loaded()

func turn_on_light():
	player.get_node("PointLight2D").hide()
	get_node("CanvasModulate").hide()

func turn_off_light():
	player.get_node("PointLight2D").show()
	get_node("CanvasModulate").show()
