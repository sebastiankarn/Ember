class_name SavedPlayerData
extends SavedData

@export var character_id:int
@export var character_traits:Dictionary
@export var inventory_data:Dictionary
@export var naked_gear:Dictionary
@export var quest_requirements_tracking:Dictionary
@export var skills_data:Dictionary
@export var equipment_data:Dictionary
@export var player_stats:Dictionary
@export var equipment_stats:Dictionary
@export var quest_data:Dictionary
@export var loaded_skills:Dictionary
@export var user_name:String
@export var profession:String
@export var stat_points:int
@export var skill_points:int
@export var health:int
@export var mana:int
@export var autoAttacking:bool
@export var skill_Knight:bool
@export var skill_Ninja:bool
@export var skill_1A:bool
@export var skill_1B:bool
@export var skill_2A:bool
@export var skill_2B:bool
@export var skill_2C:bool
@export var skill_2D:bool
@export var skill_3A:bool
@export var skill_3B:bool
@export var skill_4A:bool
@export var skill_4B:bool
@export var rate_of_fire:int
@export var gold:int
@export var curXp:int
@export var xpToNextLevel:int
@export var interactDist:int
@export var attackDist:int
@export var ranged_auto:bool

func to_dict(include_identity:bool = true) -> Dictionary:
	# First get the base class dictionary
	var dict = super.to_dict()

	# Add all SavedPlayerData specific fields (excluding identity by default for remote storage)
	var payload = {
		"character_id": character_id,
		"character_traits": character_traits,
		"inventory_data": inventory_data,
		"naked_gear": naked_gear,
		"quest_requirements_tracking": quest_requirements_tracking,
		"skills_data": skills_data,
		"equipment_data": equipment_data,
		"player_stats": player_stats,
		"equipment_stats": equipment_stats,
		"quest_data": quest_data,
		"loaded_skills": loaded_skills,
		"stat_points": stat_points,
		"skill_points": skill_points,
		"health": health,
		"mana": mana,
		"autoAttacking": autoAttacking,
		"skill_Knight": skill_Knight,
		"skill_Ninja": skill_Ninja,
		"skill_1A": skill_1A,
		"skill_1B": skill_1B,
		"skill_2A": skill_2A,
		"skill_2B": skill_2B,
		"skill_2C": skill_2C,
		"skill_2D": skill_2D,
		"skill_3A": skill_3A,
		"skill_3B": skill_3B,
		"skill_4A": skill_4A,
		"skill_4B": skill_4B,
		"rate_of_fire": rate_of_fire,
		"gold": gold,
		"curXp": curXp,
		"xpToNextLevel": xpToNextLevel,
		"interactDist": interactDist,
		"attackDist": attackDist,
		"ranged_auto": ranged_auto
	}
	if include_identity:
		payload["user_name"] = user_name
		payload["profession"] = profession
	dict.merge(payload)
	return dict

static func from_dict(data: Dictionary) -> SavedPlayerData:
	var player_data = SavedPlayerData.new()

	var _get = func(dict:Dictionary, key:String, default_value:Variant = null):
		return dict[key] if dict.has(key) else default_value

	# Base class fields
	var pos_dict = _get.call(data, "position", {"x":0, "y":0})
	var px = pos_dict["x"] if pos_dict.has("x") else 0
	var py = pos_dict["y"] if pos_dict.has("y") else 0
	player_data.position = Vector2(px, py)
	player_data.scene_path = str(_get.call(data, "scene_path", "res://Player.tscn"))

	# SavedPlayerData specific
	player_data.character_id = int(_get.call(data, "character_id", 0))
	player_data.character_traits = _get.call(data, "character_traits", {})
	player_data.inventory_data = _get.call(data, "inventory_data", {})
	player_data.naked_gear = _get.call(data, "naked_gear", {})
	player_data.quest_requirements_tracking = _get.call(data, "quest_requirements_tracking", {})
	player_data.skills_data = _get.call(data, "skills_data", {})
	player_data.equipment_data = _get.call(data, "equipment_data", {})
	player_data.player_stats = _get.call(data, "player_stats", {})
	player_data.equipment_stats = _get.call(data, "equipment_stats", {})
	player_data.quest_data = _get.call(data, "quest_data", {})
	player_data.loaded_skills = _get.call(data, "loaded_skills", {})
	player_data.user_name = str(_get.call(data, "user_name", ""))
	player_data.profession = str(_get.call(data, "profession", ""))
	player_data.stat_points = int(_get.call(data, "stat_points", 0))
	player_data.skill_points = int(_get.call(data, "skill_points", 0))
	player_data.health = int(_get.call(data, "health", 0))
	player_data.mana = int(_get.call(data, "mana", 0))
	player_data.autoAttacking = bool(_get.call(data, "autoAttacking", false))
	player_data.skill_Knight = bool(_get.call(data, "skill_Knight", false))
	player_data.skill_Ninja = bool(_get.call(data, "skill_Ninja", false))
	player_data.skill_1A = bool(_get.call(data, "skill_1A", false))
	player_data.skill_1B = bool(_get.call(data, "skill_1B", false))
	player_data.skill_2A = bool(_get.call(data, "skill_2A", false))
	player_data.skill_2B = bool(_get.call(data, "skill_2B", false))
	player_data.skill_2C = bool(_get.call(data, "skill_2C", false))
	player_data.skill_2D = bool(_get.call(data, "skill_2D", false))
	player_data.skill_3A = bool(_get.call(data, "skill_3A", false))
	player_data.skill_3B = bool(_get.call(data, "skill_3B", false))
	player_data.skill_4A = bool(_get.call(data, "skill_4A", false))
	player_data.skill_4B = bool(_get.call(data, "skill_4B", false))
	player_data.rate_of_fire = int(_get.call(data, "rate_of_fire", 0))
	player_data.gold = int(_get.call(data, "gold", 0))
	player_data.curXp = int(_get.call(data, "curXp", 0))
	player_data.xpToNextLevel = int(_get.call(data, "xpToNextLevel", 0))
	player_data.interactDist = int(_get.call(data, "interactDist", 0))
	player_data.attackDist = int(_get.call(data, "attackDist", 0))
	player_data.ranged_auto = bool(_get.call(data, "ranged_auto", false))

	return player_data
