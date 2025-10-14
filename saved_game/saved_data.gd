class_name SavedData
extends Resource

@export var position:Vector2
@export var scene_path:String

func to_dict() -> Dictionary:
	return {
		"type": "SavedData",
		"position": {
			"x": position.x,
			"y": position.y
		},
		"scene_path": scene_path
	}

static func from_dict(data: Dictionary) -> SavedData:
	var saved_data = SavedData.new()
	var pos_dict = data.get("position", {"x":0, "y":0})
	var px = pos_dict.get("x", 0)
	var py = pos_dict.get("y", 0)
	saved_data.position = Vector2(px, py)
	saved_data.scene_path = str(data.get("scene_path", ""))
	return saved_data
