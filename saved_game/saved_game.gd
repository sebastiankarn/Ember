class_name SavedGame
extends Resource

@export var map_current_level:int
@export var map_maximum_level:int
@export var lightOn:int
@export var player_data:SavedPlayerData
@export var saved_data:Array[SavedData] = []

func to_dict(include_identity:bool = true) -> Dictionary:
	var saved_data_array = []
	for data in saved_data:
		saved_data_array.append(data.to_dict())

	return {
		"map_current_level": map_current_level,
		"map_maximum_level": map_maximum_level,
		"lightOn": lightOn,
		"player_data": player_data.to_dict(include_identity),
		"saved_data": saved_data_array
	}

# Produce a Firestore-safe dictionary (no Objects/Resources; Vector2 flattened).
func to_firestore_dict() -> Dictionary:
	# Exclude identity for remote gameState per Option A design.
	var base = to_dict(false)
	return _sanitize_value(base)

func _sanitize_value(value):
	match typeof(value):
		TYPE_DICTIONARY:
			var out = {}
			for k in value.keys():
				out[k] = _sanitize_value(value[k])
			return out
		TYPE_ARRAY:
			var arr = []
			for v in value:
				arr.append(_sanitize_value(v))
			return arr
		TYPE_OBJECT:
			# Ignore non-Resource objects (should not appear after to_dict())
			return null
		_:
			# Special handling for Vector2 isn't needed because to_dict already converts, but keep safety.
			if value is Vector2:
				return {"x": value.x, "y": value.y}
			return value

static func from_dict(data: Dictionary) -> SavedGame:
	var game = SavedGame.new()

	# Helper lambda to fetch either plain or firebase-wrapped
	var unwrap = func(v):
		if v == null:
			return null
		if typeof(v) == TYPE_DICTIONARY:
			if v.has("mapValue") or v.has("arrayValue") or v.has("integerValue") or v.has("doubleValue") or v.has("stringValue"):
				return FirebaseConverter.get_firebase_value(v)
		return v

	var mc = unwrap.call(data.get("map_current_level"))
	var mm = unwrap.call(data.get("map_maximum_level"))
	var lo = unwrap.call(data.get("lightOn"))
	if mc == null:
		mc = 1
	if mm == null:
		mm = 1
	if lo == null:
		lo = -1
	game.map_current_level = int(mc)
	game.map_maximum_level = int(mm)
	game.lightOn = int(lo)
	# Use static helper for deep unwrap

	var pd_raw = unwrap.call(data.get("player_data"))
	if pd_raw:
		pd_raw = _deep_unwrap_value(pd_raw)
		if typeof(pd_raw) == TYPE_DICTIONARY:
			if DebugConfig.VERBOSE or DebugConfig.LOG_SAVE_LOAD:
				print("[SavedGame.from_dict] player_data keys after deep unwrap:", pd_raw.keys())
		game.player_data = SavedPlayerData.from_dict(pd_raw)
	else:
		game.player_data = SavedPlayerData.new()

	var saved_data_array = unwrap.call(data.get("saved_data"))
	if saved_data_array:
		for saved_item in saved_data_array:
			var unwrapped_item = _deep_unwrap_value(saved_item)
			var type = unwrapped_item.get("type", "SavedData") if typeof(unwrapped_item) == TYPE_DICTIONARY else "SavedData"
			if type == "SavedChestData":
				game.saved_data.append(SavedChestData.from_dict(unwrapped_item))
			else:
				game.saved_data.append(SavedData.from_dict(unwrapped_item))

	return game

# Static helper reused to unwrap nested firebase wrappers and plain dicts/arrays
static func _deep_unwrap_value(v):
	if v == null:
		return null
	var t = typeof(v)
	if t == TYPE_DICTIONARY:
		# Firestore map structure
		if v.has("mapValue"):
			var fields = {}
			if v.mapValue and typeof(v.mapValue) == TYPE_DICTIONARY:
				fields = v.mapValue.get("fields", {})
			var out_map = {}
			for k in fields.keys():
				out_map[k] = _deep_unwrap_value(fields[k])
			return out_map
		# Firestore array structure
		if v.has("arrayValue"):
			var values = []
			if v.arrayValue and typeof(v.arrayValue) == TYPE_DICTIONARY:
				values = v.arrayValue.get("values", [])
			var out_arr = []
			for item in values:
				out_arr.append(_deep_unwrap_value(item))
			return out_arr
		# Primitive wrappers (also include nullValue guard)
		if v.has("nullValue"):
			return null
		if v.has("integerValue") or v.has("doubleValue") or v.has("stringValue") or v.has("booleanValue"):
			return FirebaseConverter.get_firebase_value(v)
		# Plain dict
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
