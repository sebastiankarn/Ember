# Helper class to handle Firebase conversions
class_name FirebaseConverter
extends Object

static func _get_type_mapping() -> Dictionary:
	return {
		"SavedGame": SavedGame,
		"SavedData": SavedData,
		"SavedPlayerData": SavedPlayerData,
		"Resource": Resource
	}

static func to_firebase_dict(resource: Resource) -> Dictionary:
	var dict = {}

	for property in resource.get_property_list():
		if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var prop_name = property["name"]
			var value = resource.get(prop_name)

			dict[prop_name] = _convert_to_firebase_value(value)

	# Use the actual class name instead of get_class()
	var name_of_class = ""
	if resource is SavedGame:
		name_of_class = "SavedGame"
	elif resource is SavedPlayerData:
		name_of_class = "SavedPlayerData"
	elif resource is SavedData:
		name_of_class = "SavedData"
	else:
		name_of_class = "Resource"

	dict["_godot_type"] = {"stringValue": name_of_class}
	return dict

static func _convert_to_firebase_value(value):
	match typeof(value):
		TYPE_VECTOR2:
			return {
				"x": {"doubleValue": value.x},
				"y": {"doubleValue": value.y}
			}
		TYPE_VECTOR3:
			return {
				"x": {"doubleValue": value.x},
				"y": {"doubleValue": value.y},
				"z": {"doubleValue": value.z}
			}
		TYPE_INT:
			return {"integerValue": value}
		TYPE_FLOAT:
			return {"doubleValue": value}
		TYPE_STRING:
			return {"stringValue": value}
		TYPE_BOOL:
			return {"booleanValue": value}
		TYPE_ARRAY:
			var array_values = []
			for item in value:
				array_values.append(_convert_to_firebase_value(item))
			return {"arrayValue": {"values": array_values}}
		TYPE_DICTIONARY:
			var map_fields = {}
			for key in value:
				map_fields[key] = _convert_to_firebase_value(value[key])
			return {"mapValue": {"fields": map_fields}}
		TYPE_OBJECT:
			if value == null:
				return {"nullValue": null}
			if value is Resource:
				return {"mapValue": {"fields": to_firebase_dict(value)}}
	return {"nullValue": null}

static func _unwrap_firebase_value(value: Dictionary):
	# Helper function to unwrap nested Firebase values
	if value.has("mapValue") and value["mapValue"].has("fields"):
		var test = value["mapValue"]["fields"]
		var test2 = test.keys()[0]
		var test3 = test.values()[0]
		return test3
		#return value["mapValue"]["fields"]
	return value

static func from_firebase_dict(data: Dictionary) -> Resource:
	# Unwrap the top-level fields if they exist
	data = _unwrap_firebase_value(data)

	if not data.has("_godot_type"):
		push_error("No Godot type information in Firebase data")
		return null

	# Get the type from the nested structure
	var type_value = _unwrap_firebase_value(data["_godot_type"])
	var type_name = type_value["stringValue"]

	var type_mapping = _get_type_mapping()
	if not type_mapping.has(type_name):
		push_error("Unknown type: " + type_name)
		return null

	var resource = type_mapping[type_name].new()

	for key in data:
		if key == "_godot_type":
			continue

		var value = _convert_from_firebase_value(data[key])
		if value != null:
			resource.set(key, value)

	return resource

static func _convert_from_firebase_value(value):
	if typeof(value) != TYPE_DICTIONARY:
		return value

	# Unwrap the value if it has mapValue.fields structure
	value = _unwrap_firebase_value(value)

	if value.has("integerValue"):
		return int(value["integerValue"])
	elif value.has("doubleValue"):
		return float(value["doubleValue"])
	elif value.has("stringValue"):
		return value["stringValue"]
	elif value.has("booleanValue"):
		return bool(value["booleanValue"])
	elif value.has("nullValue"):
		return null
	elif value.has("mapValue"):
		var fields = value["mapValue"].get("fields", {})

		# Check if this is a Vector2
		if fields.has("x") and fields.has("y") and fields.size() == 2:
			return Vector2(
				_convert_from_firebase_value(fields["x"]),
				_convert_from_firebase_value(fields["y"])
			)

		# Check if this is a Vector3
		if fields.has("x") and fields.has("y") and fields.has("z") and fields.size() == 3:
			return Vector3(
				_convert_from_firebase_value(fields["x"]),
				_convert_from_firebase_value(fields["y"]),
				_convert_from_firebase_value(fields["z"])
			)

		# Check if this is a Godot resource
		if fields.has("_godot_type"):
			return from_firebase_dict(fields)

		# Regular dictionary
		var dict = {}
		for key in fields:
			dict[key] = _convert_from_firebase_value(fields[key])
		return dict

	elif value.has("arrayValue"):
		var array = []
		for item in value["arrayValue"].get("values", []):
			array.append(_convert_from_firebase_value(item))
		return array

	return null

# Helper functions to handle Firebase value types
static func get_firebase_value(field_data):
	if not field_data:
		return null

	# Handle different Firebase value types
	if "integerValue" in field_data:
		return int(field_data.integerValue)
	elif "doubleValue" in field_data:
		return float(field_data.doubleValue)
	elif "stringValue" in field_data:
		return field_data.stringValue
	elif "booleanValue" in field_data:
		return field_data.booleanValue
	elif "nullValue" in field_data:
		return null
	elif "mapValue" in field_data:
		var result = {}
		if "fields" in field_data.mapValue:
			for key in field_data.mapValue.fields:
				result[key] = get_firebase_value(field_data.mapValue.fields[key])
		return result
	elif "arrayValue" in field_data:
		var result = []
		if "values" in field_data.arrayValue:
			for value in field_data.arrayValue.values:
				result.append(get_firebase_value(value))
		return result
	return null
