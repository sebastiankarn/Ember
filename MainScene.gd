extends Node2D

@onready var player = get_node("/root/MainScene/Player")
@onready var character_sheet = $CanvasLayer/CharacterSheet
@onready var inventory = $CanvasLayer/Inventory
@onready var skill_bar = $CanvasLayer/SkillBar
@onready var skill_panel = $CanvasLayer/SkillPanel
@onready var cast_bar = $CanvasLayer/CastBar
@onready var settings_window = $CanvasLayer/SettingsWindow
@onready var quest_log = $CanvasLayer/QuestLog
@onready var world_map = $CanvasLayer/WorldMap

var light_turned_on = -1

var map_current_level = 2
var map_maximum_level = 80

var COLLECTION_ID = "test_stats" # legacy single-user save (deprecated)
var firebase_character_id: String = "" # Firestore character document id
var _autosave_timer: Timer
var _autosave_enabled: bool = false
var _is_saving: bool = false

func _ready():
	Engine.max_fps = 60
	_setup_autosave()
	# Auto-resolve firebase character id if mapping present
	if PlayerData.firebase_character_ids.has(PlayerData.character_id):
		firebase_character_id = PlayerData.firebase_character_ids[PlayerData.character_id]
		if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
			print("[MainScene] Resolved firebase_character_id: %s" % firebase_character_id)
	load_game()


func _unhandled_input(event):
	if event.is_action_pressed("ui_character_sheet"):
		press_character_sheet()
	if event.is_action_pressed("ui_inventory"):
		press_inventory()
	if event.is_action_pressed("ui_skill_panel"):
		press_skills()
	if event.is_action_pressed("ui_quest_log"):
		press_quest_log()
	if event.is_action_pressed("ui_map"):
		press_map()
	if event.is_action_pressed("ui_cancel"):
		var ui_hidden = check_if_ui_hidden()
		if !ui_hidden:
			hide_all_ui()
		else:
			press_settings()


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


func press_map():
	world_map.visible = !world_map.visible
	hide_tooltips(skill_panel)

func press_settings():
	settings_window.visible = !settings_window.visible


func check_if_ui_hidden():
	if skill_panel.visible or inventory.visible or character_sheet.visible or $CanvasLayer/NpcInventory.visible or $CanvasLayer/NpcQuestWindow.visible or settings_window.visible or quest_log.visible or world_map.visible:
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
	world_map.hide()


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
	if _is_saving:
		if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
			print("[Autosave] Skipping save; previous save still in progress")
		return
	_is_saving = true
	var saved_game:SavedGame = SavedGame.new()

	saved_game.map_current_level = map_current_level
	saved_game.map_maximum_level = map_maximum_level
	saved_game.lightOn = light_turned_on
	saved_game.player_data = player.on_save_game()
	if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
		print("[Save] Captured player_data.position:", saved_game.player_data.position, "map_current_level:", map_current_level, "lightOn:", light_turned_on)
	var saved_data:Array[SavedData] = []
	get_tree().call_group("game_events", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
		print("[Save] Collected saved_data entries:", saved_game.saved_data.size())

	# New architecture: save inside character document
	if firebase_character_id != "":
		await FirebaseCharacters.save_game(firebase_character_id, saved_game)
	else:
		print("[WARN] No firebase_character_id set; skipping remote save.")
	if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
		print("[Save] Saved player name:", saved_game.player_data.user_name, "level:", saved_game.player_data.player_stats.get("Level", "?"))
	ResourceSaver.save(saved_game, "user://savegame" + PlayerData.user_name + str(PlayerData.character_id) + ".tres")
	_is_saving = false
	if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
		print("[Autosave] Save complete")

func _setup_autosave():
	# Create or reuse timer
	_autosave_timer = Timer.new()
	_autosave_timer.one_shot = false
	_autosave_timer.wait_time = DebugConfig.AUTOSAVE_INTERVAL_SEC
	add_child(_autosave_timer)
	_autosave_timer.timeout.connect(_on_autosave_timeout)
	if DebugConfig.AUTOSAVE_ENABLED:
		enable_autosave()

func enable_autosave():
	_autosave_enabled = true
	if _autosave_timer:
		_autosave_timer.start()
	if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
		print("[Autosave] Enabled (interval %ss)" % DebugConfig.AUTOSAVE_INTERVAL_SEC)

func disable_autosave():
	_autosave_enabled = false
	if _autosave_timer:
		_autosave_timer.stop()
	if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
		print("[Autosave] Disabled")

func toggle_autosave():
	if _autosave_enabled:
		disable_autosave()
	else:
		enable_autosave()

func _on_autosave_timeout():
	if not _autosave_enabled:
		return
	if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
		print("[Autosave] Timer fired -> saving")
	save_game()

func convert_saved_game_to_dict(saved_game: SavedGame) -> Dictionary:
	var dict = {}

	# Convert primitive types directly
	dict["map_current_level"] = saved_game.map_current_level
	dict["map_maximum_level"] = saved_game.map_maximum_level
	dict["lightOn"] = saved_game.lightOn

	# Convert player data (assuming on_save_game() returns a custom object)
	if saved_game.player_data:
		dict["player_data"] = convert_custom_object_to_dict(saved_game.player_data)

	# Convert saved_data array
	if saved_game.saved_data:
		dict["saved_data"] = []
		for saved_data in saved_game.saved_data:
			dict["saved_data"].append(convert_custom_object_to_dict(saved_data))

	return dict

func convert_custom_object_to_dict(obj) -> Dictionary:
	var dict = {}

	# Use reflection to get all properties of the object
	var properties = obj.get_property_list()

	for prop in properties:
		# Skip certain system properties
		if prop["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var prop_name = prop["name"]
			var value = obj.get(prop_name)

			# Special handling for Vector2 and Vector3
			if value is Vector2:
				dict[prop_name] = {
					"x": value.x,
					"y": value.y
				}
			elif value is Vector3:
				dict[prop_name] = {
					"x": value.x,
					"y": value.y,
					"z": value.z
				}
			# Recursively convert nested custom objects
			elif typeof(value) == TYPE_OBJECT and value != null:
				# Check if it's a built-in type that we don't want to convert
				var script = value.get_script()
				if script != null:
					dict[prop_name] = convert_custom_object_to_dict(value)
				else:
					# For built-in objects, just store them as is
					dict[prop_name] = value
			else:
				dict[prop_name] = value

	return dict

func convert_dict_to_custom_object(data: Dictionary, target_class):
	var obj = target_class.new()

	for key in data.keys():
		var value = data[key]

		# Special handling for Vector2 and Vector3
		if typeof(value) == TYPE_DICTIONARY:
			# Check if it looks like a Vector2
			if value.has("x") and value.has("y") and value.keys().size() == 2:
				obj.set(key, Vector2(value["x"], value["y"]))
			# Check if it looks like a Vector3
			elif value.has("x") and value.has("y") and value.has("z") and value.keys().size() == 3:
				obj.set(key, Vector3(value["x"], value["y"], value["z"]))
			# Handle nested objects
			else:
				# If the value is a dictionary and the target property is a custom object
				var prop_type = obj.get_script().get_script_property_list().filter(func(prop): return prop["name"] == key)
				if prop_type and prop_type[0].has("type"):
					var nested_obj = convert_dict_to_custom_object(value, load(prop_type[0]["type"]))
					obj.set(key, nested_obj)
				else:
					# If not a special case, set as is
					obj.set(key, value)
		else:
			# For simple types, set directly
			obj.set(key, value)

	return obj

func parse_firebase_document(data: Dictionary) -> SavedGame:
	var saved_game = SavedGame.new()

	# Recursively parse the dictionary, converting Firebase-specific types
	for key in data:
		var value = convert_firebase_value(data[key])
		saved_game.set(key, value)

	return saved_game

func convert_firebase_value(value):
	if typeof(value) == TYPE_DICTIONARY:
		# Check for specific Firebase value types
		if value.has("integerValue"):
			return int(value["integerValue"])
		elif value.has("doubleValue"):
			return float(value["doubleValue"])
		elif value.has("stringValue"):
			return value["stringValue"]
		elif value.has("booleanValue"):
			return bool(value["booleanValue"])
		elif value.has("mapValue"):
			# Recursively convert nested map
			var nested_dict = {}
			var fields = value["mapValue"].get("fields", {})
			for key in fields:
				nested_dict[key] = convert_firebase_value(fields[key])
			return nested_dict
		elif value.has("arrayValue"):
			# Convert array
			var array = []
			var values = value["arrayValue"].get("values", [])
			for item in values:
				array.append(convert_firebase_value(item))
			return array

	return value


func load_game():
	var saved_game_new_new
	if firebase_character_id != "":
		var remote_saved:SavedGame = await FirebaseCharacters.load_saved_game(firebase_character_id)
		if remote_saved:
			if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
				print("[Load] Remote saved_game player_data.position:", remote_saved.player_data.position, "map_current_level:", remote_saved.map_current_level)
			# override local file with remote state
			ResourceSaver.save(remote_saved, "user://savegame" + PlayerData.user_name + str(PlayerData.character_id) + ".tres")
			saved_game_new_new = remote_saved
	else:
		if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
			print("[Load] Skipping remote load; empty firebase_character_id. Mapping: ", PlayerData.firebase_character_ids)

	var file_path = "user://savegame"  + PlayerData.user_name + str(PlayerData.character_id) + ".tres"
	if !FileAccess.file_exists(file_path):
		return
	var saved_game:SavedGame = load(file_path) as SavedGame
	# Remote firebase parsing removed in new architecture (saved_game_firebase unused)
	if saved_game == null:
		return

	if saved_game_new_new:
		if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
			print("[Load] Using remote saved game")
		print(saved_game_new_new)
		saved_game = saved_game_new_new
	else:
		if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
			print("[Load] Using local saved game")
		print(saved_game)
	if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
		print("[Load] Pre-apply saved_game.player_data.position:", saved_game.player_data.position, "map_current_level:", saved_game.map_current_level)
	if saved_game and saved_game.player_data:
		if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
			print("[Load] Pre-apply player_data name:", saved_game.player_data.user_name, "pos:", saved_game.player_data.position)
	#IF NEW CHARACTER
	if saved_game.player_data == null:
		if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
			print("[Load] saved_game.player_data is null; initializing new player data")
		saved_game.player_data = SavedPlayerData.new()
	if saved_game.player_data.player_stats.is_empty():
		player.load_new_character_data(saved_game.player_data)
		#player.on_load_game(PlayerData.player_data)
		player.reload_all_components()
		await get_tree().create_timer(2).timeout
		complete_loading()
		return
	map_current_level = saved_game.map_current_level
	map_maximum_level = saved_game.map_maximum_level

	#HANDLE PLAYER, UI
	player.on_load_game(saved_game.player_data)
	if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
		print("[Load] After applying player_data -> player.name:", player.user_name, "pos:", player.position)
		print("[Load] PlayerData stats Level:", PlayerData.player_stats.get("Level"), "curXp:", PlayerData.player_stats.get("curXp"))

	#HANDLE ITEMS/MOBS/BOSSES/ENVIRONMENT
	get_tree().call_group("game_events", "on_before_load_game")
	var saved_data = saved_game.saved_data
	for item in saved_data:
		var scene = load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		add_child(restored_node)
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)
	if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
		print("[Load] Restored saved_data entries:", saved_data.size())
		print("[Load] Player name after load:", player.user_name, "Level stat:", PlayerData.player_stats.get("Level", "?"))

	#HANDLE LIGHTS, NEEDS TO WAIT A SECOND TO LOAD CORRECTLY
	await get_tree().create_timer(0.5).timeout
	if saved_game.lightOn == 1:
		turn_on_bright_light()
	elif saved_game.lightOn == 0:
		turn_on_light()
	elif saved_game.lightOn == -1:
		turn_off_light()
	elif saved_game.lightOn == -2:
		turn_off_light_dark()
	else:
		turn_off_light()
	complete_loading()


func complete_loading():
	var loading_scenes = get_tree().get_nodes_in_group("LoadingScreen")
	for loading_scene in loading_scenes:
		if loading_scene.has_method("main_scene_loaded"):
			loading_scene.main_scene_loaded()


func turn_on_light():
	light_turned_on = 0
	player.get_node("PointLight2D").energy = 0.4
	get_node("CanvasModulate").set_color(Color("8799c3"))
	var cave_entrance_list = get_tree().get_nodes_in_group("CaveEntrance")
	for entrance in cave_entrance_list:
		entrance.show()


func turn_off_light():
	light_turned_on = -1
	player.get_node("PointLight2D").energy = 1.1
	get_node("CanvasModulate").set_color(Color("282620"))
	var cave_entrance_list = get_tree().get_nodes_in_group("CaveEntrance")
	for entrance in cave_entrance_list:
		entrance.hide()


func turn_on_bright_light():
	light_turned_on = 1
	player.get_node("PointLight2D").energy = 0
	get_node("CanvasModulate").set_color(Color("ffffff"))
	var cave_entrance_list = get_tree().get_nodes_in_group("CaveEntrance")
	for entrance in cave_entrance_list:
		entrance.show()

func turn_off_light_dark():
	light_turned_on = -2
	player.get_node("PointLight2D").energy = 0.8
	get_node("CanvasModulate").set_color(Color(0.175, 0.023, 0.029))
	var cave_entrance_list = get_tree().get_nodes_in_group("CaveEntrance")
	for entrance in cave_entrance_list:
		entrance.hide()
