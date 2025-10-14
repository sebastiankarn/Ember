class_name SavedChestData
extends SavedData

@export var monster_name:String
@export var loot_data:Dictionary

func to_dict() -> Dictionary:
	var base_dict = super.to_dict()
	base_dict["type"] = "SavedChestData"  # Override type
	base_dict["monster_name"] = monster_name
	base_dict["loot_data"] = loot_data
	return base_dict

static func from_dict(data: Dictionary) -> SavedChestData:
	var chest_data = SavedChestData.new()
	var pos_dict = data.get("position", {"x":0, "y":0})
	var px = pos_dict.get("x", 0)
	var py = pos_dict.get("y", 0)
	chest_data.position = Vector2(px, py)
	chest_data.scene_path = str(data.get("scene_path", ""))
	chest_data.monster_name = str(data.get("monster_name", "Chest"))
	chest_data.loot_data = data.get("loot_data", {})
	return chest_data
