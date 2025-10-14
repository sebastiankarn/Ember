# Centralized Firebase Character operations per new single-collection architecture
# Collection: characters
# Each document: { userId, name, class, level, createdAt, lastPlayed, gameState: {...} }
# gameState will mirror the existing SavedGame -> to_dict() structure plus any runtime state needed
# Option A: name/class (identity) live ONLY at top-level doc; gameState excludes them.
# On load we inject these into player_data if missing for in-memory convenience.

class_name FirebaseCharacters
extends Object

const COLLECTION := "characters"

# Helper to unwrap firebase field wrapper dictionaries into primitive Godot values.
static func _unwrap_value(v):
	if v == null:
		return null
	if typeof(v) == TYPE_DICTIONARY:
		if v.has("mapValue") or v.has("arrayValue") or v.has("integerValue") or v.has("doubleValue") or v.has("stringValue") or v.has("booleanValue"):
			return FirebaseConverter.get_firebase_value(v)
	return v

# Deep recursive unwrap of Firestore REST-style value wrappers into plain GD primitives.
static func _deep_unwrap_value(v):
	if v == null:
		return null
	var t = typeof(v)
	if t == TYPE_DICTIONARY:
		# Firestore map
		if v.has("mapValue"):
			var fields = {}
			if v.mapValue and typeof(v.mapValue) == TYPE_DICTIONARY:
				fields = v.mapValue.get("fields", {})
			var out_map = {}
			for k in fields.keys():
				out_map[k] = _deep_unwrap_value(fields[k])
			return out_map
		# Firestore array
		if v.has("arrayValue"):
			var values = []
			if v.arrayValue and typeof(v.arrayValue) == TYPE_DICTIONARY:
				values = v.arrayValue.get("values", [])
			var out_arr = []
			for item in values:
				out_arr.append(_deep_unwrap_value(item))
			return out_arr
		# Primitive wrappers
		if v.has("integerValue") or v.has("doubleValue") or v.has("stringValue") or v.has("booleanValue"):
			return FirebaseConverter.get_firebase_value(v)
		# Plain dict: recurse each value
		var plain_out = {}
		for k2 in v.keys():
			plain_out[k2] = _deep_unwrap_value(v[k2])
		return plain_out
	elif t == TYPE_ARRAY:
		var arr_out = []
		for e in v:
			arr_out.append(_deep_unwrap_value(e))
		return arr_out
	else:
		return v

static func _now_ts() -> int:
	# Local approximation; replace with server-side sentinel if plugin supports it.
	return int(Time.get_unix_time_from_system())

static func _assert_auth() -> String:
	var tries = 0
	while tries < 30:
		var auth = Firebase.Auth.auth
		if auth and auth.localid:
			return auth.localid
		tries += 1
		await Engine.get_main_loop().process_frame
	push_error("Firebase auth not ready (no user) after wait.")
	return ""

static func create_character(character_name: String, character_class: String, saved_game: SavedGame) -> String:
	var user_id = await _assert_auth()
	if user_id == "":
		return ""

	var now = _now_ts()
	# Ensure saved_game has basic player identity before initial write
	if saved_game and saved_game.player_data:
		if saved_game.player_data.user_name == null or saved_game.player_data.user_name == "":
			saved_game.player_data.user_name = character_name
		if saved_game.player_data.profession == null or saved_game.player_data.profession == "":
			saved_game.player_data.profession = character_class

	var character_doc: Dictionary = {
		"userId": user_id,
		"name": character_name,
		"class": character_class,
		"level": 1,
		"createdAt": now,
		"lastPlayed": now,
		"gameState": saved_game.to_dict()
	}

	var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION)
	# Some Godot Firebase plugins require explicit document ID. Generate a pseudo-unique id.
	var char_id = str(Time.get_unix_time_from_system()) + "_" + str(randi())
	var created = await collection.add(char_id, character_doc)
	if created:
		print("Character created with id: %s" % char_id)
		return char_id
	else:
		push_error("Failed creating character")
		return ""

static func list_user_characters() -> Array:
	var user_id = await _assert_auth()
	if user_id == "":
		return []
	var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION)
	var docs = []
	if collection and collection.has_method("query"):
		var query: FirestoreQuery = collection.query()
		query = query.where("userId", Firebase.Firestore.OPERATOR.EQUAL, user_id)
		docs = await query.get_documents()
	else:
		print("[FirebaseCharacters.list_user_characters] Query builder missing; falling back to full collection fetch")
		if collection and collection.has_method("get_documents"):
			docs = await collection.get_documents()
	var out := []
	for d in docs:
		if !d.document: # defensive
			continue
			# d.document is firebase raw
		var level_raw = d.document.level if d.document.has("level") else 1
		var name_raw = d.document.name if d.document.has("name") else "Unnamed"
		var class_raw = d.document.class if d.document.has("class") else ""
		var last_played_raw = d.document.lastPlayed if d.document.has("lastPlayed") else null
		var level = int(_unwrap_value(level_raw))
		var name_val = str(_unwrap_value(name_raw))
		var class_val = str(_unwrap_value(class_raw))
		var last_played = _unwrap_value(last_played_raw)
		out.append({
			"id": d.doc_name,
			"name": name_val,
			"class": class_val,
			"level": level,
			"lastPlayed": last_played
		})
	return out

static func load_character(character_id: String) -> Dictionary:
	var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION)
	var doc_wrapper = await collection.get_doc(character_id)
	if doc_wrapper and doc_wrapper.get("document"):
		return doc_wrapper.get("document")
	push_error("Character not found or no data: %s" % character_id)
	return {}

static func load_saved_game(character_id: String) -> SavedGame:
	var doc = await load_character(character_id)
	if doc.is_empty():
		return null
	if !doc.has("gameState"):
		push_error("Character document missing gameState")
		return null
	var game_state_raw = doc.gameState
	var game_state = _deep_unwrap_value(game_state_raw)
	if game_state and typeof(game_state) == TYPE_DICTIONARY:
		if DebugConfig.VERBOSE or DebugConfig.LOG_FIREBASE:
			if game_state.has("player_data") and typeof(game_state.player_data) == TYPE_DICTIONARY and game_state.player_data.has("position"):
				print("[FirebaseCharacters.load_saved_game] Unwrapped gameState.player_data.position:", game_state.player_data.position)
			print("[FirebaseCharacters.load_saved_game] Unwrapped map_current_level:", game_state.get("map_current_level"))

	var saved_game = SavedGame.from_dict(_wrap_for_saved_game(game_state))
	# Fallback: inject top-level name/class if player_data lacks them
	if saved_game and saved_game.player_data:
		if (saved_game.player_data.user_name == null or saved_game.player_data.user_name == "") and doc.has("name"):
			if DebugConfig.VERBOSE or DebugConfig.LOG_FIREBASE:
				print("[FirebaseCharacters.load_saved_game] Injecting missing user_name from top-level doc")
			var uname_unwrapped = _unwrap_value(doc.name)
			saved_game.player_data.user_name = uname_unwrapped if uname_unwrapped != null else ""
		if (saved_game.player_data.profession == null or saved_game.player_data.profession == "") and doc.has("class"):
			if DebugConfig.VERBOSE or DebugConfig.LOG_FIREBASE:
				print("[FirebaseCharacters.load_saved_game] Injecting missing profession from top-level doc")
			var class_unwrapped = _unwrap_value(doc.class)
			saved_game.player_data.profession = class_unwrapped if class_unwrapped != null else ""
		if DebugConfig.VERBOSE or DebugConfig.LOG_FIREBASE:
			print("[FirebaseCharacters.load_saved_game] Identity applied -> name:", saved_game.player_data.user_name, "class:", saved_game.player_data.profession)
	return saved_game

# SavedGame.from_dict currently expects firebase-wrapped fields; for now we just emulate minimal wrapper
static func _wrap_for_saved_game(gs: Dictionary) -> Dictionary:
	# If values are already primitive we can mimic firebase converter input shape using simple maps
	# For now return directly; adjust if converter requires nested types.
	return gs

static func save_game(character_id: String, saved_game: SavedGame):
	var user_id = await _assert_auth()
	if user_id == "":
		return
	var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION)
	var existing = await collection.get_doc(character_id)
	if !existing:
		push_error("[FirebaseCharacters] Cannot save; character doc %s not found." % character_id)
		return
	var sanitized_game_state = saved_game.to_firestore_dict()
	if DebugConfig.VERBOSE or DebugConfig.LOG_FIREBASE:
		if sanitized_game_state.has("player_data") and sanitized_game_state.player_data.has("position"):
			print("[FirebaseCharacters.save_game] Sanitized player_data.position:", sanitized_game_state.player_data.position)
		print("[FirebaseCharacters.save_game] Sanitized map_current_level:", sanitized_game_state.get("map_current_level"))
	var level_val = saved_game.player_data.player_stats.get("Level", 1) if saved_game.player_data and saved_game.player_data.player_stats else 1
	if DebugConfig.VERBOSE or DebugConfig.LOG_FIREBASE:
		print("[FirebaseCharacters.save_game] Character:", character_id, "user:", user_id)
		if saved_game.player_data:
			print("[FirebaseCharacters.save_game] Player name:", saved_game.player_data.user_name, "Pos:", saved_game.player_data.position)
		print("[FirebaseCharacters.save_game] gameState keys:", sanitized_game_state.keys())
	existing.add_or_update_field("gameState", sanitized_game_state)
	existing.add_or_update_field("lastPlayed", _now_ts())
	existing.add_or_update_field("level", level_val)
	var result = await collection.update(existing)
	if result:
		if DebugConfig.VERBOSE or DebugConfig.LOG_FIREBASE:
			print("[FirebaseCharacters.save_game] Saved successfully for", character_id)
	else:
		push_error("[FirebaseCharacters.save_game] Failed saving character %s" % character_id)

static func delete_character(character_id: String):
	var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION)
	var existing = await collection.get_doc(character_id)
	if !existing:
		push_error("[FirebaseCharacters] Cannot delete; doc not found %s" % character_id)
		return
	var r = await collection.delete(existing)
	if r:
		print("Deleted character %s" % character_id)
	else:
		push_error("Failed deleting character %s" % character_id)
