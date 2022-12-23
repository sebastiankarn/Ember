extends Area2D
export var goldToGive : int = 5

var dragon_data = {
	"0": {
		"ItemId": 10006,
		"MinStack": 5,
		"MaxStack": 6,
		"Chance": 0.3
	},
	"1": {
		"ItemId": 10007,
		"MinStack": 4,
		"MaxStack": 6,
		"Chance": 0.3
	},
	"2": {
		"ItemId": 10012,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"3": {
		"ItemId": 10003,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"4": {
		"ItemId": 10016,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"5": {
		"ItemId": 10018,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"6": {
		"ItemId": 10023,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"7": {
		"ItemId": 10020,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"8": {
		"ItemId": 10022,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"9": {
		"ItemId": 10023,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"10": {
		"ItemId": 10025,
		"MinStack": 2,
		"MaxStack": 6,
		"Chance": 0.3
	}
}

var skeleton_data = {
	"0": {
		"ItemId": 10004,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"1": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"2": {
		"ItemId": 10005,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"3": {
		"ItemId": 10006,
		"MinStack": 1,
		"MaxStack": 3,
		"Chance": 0.3
	},
	"4": {
		"ItemId": 10007,
		"MinStack": 1,
		"MaxStack": 3,
		"Chance": 0.3
	},
	"5": {
		"ItemId": 10008,
		"MinStack": 1,
		"MaxStack": 3,
		"Chance": 0.3
	},
	"6": {
		"ItemId": 10011,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"7": {
		"ItemId": 10015,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"8": {
		"ItemId": 10017,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"9": {
		"ItemId": 10019,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"10": {
		"ItemId": 10021,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"11": {
		"ItemId": 10025,
		"MinStack": 1,
		"MaxStack": 2,
		"Chance": 0.3
	}
}

var data = {
	"0": {
		"ItemId": 10002,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"1": {
		"ItemId": 10008,
		"MinStack": 3,
		"MaxStack": 5,
		"Chance": 1
	},
	"3": {
		"ItemId": 10025,
		"MinStack": 2,
		"MaxStack": 3,
		"Chance": 1
	}
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_interact (player):
	for i in data.keys():
		var chance = data[str(i)]["Chance"]
		var stack = null
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		randomize()
		if data[str(i)]["MinStack"] != null:
			stack = rng.randi_range(data[str(i)]["MinStack"], data[str(i)]["MaxStack"])
		if randf() <= chance:
			player.loot_item(data[str(i)]["ItemId"], stack)
		
	player.give_gold(goldToGive)
	queue_free()

func set_loot(name):
	if name == "Skeleton":
		data = skeleton_data
	if name == "Dragon":
		data = dragon_data
	
	
