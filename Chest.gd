extends Area2D
export var goldToGive : int = 5

var data = {
	"0": {
		"ItemId": 10001,
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
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"3": {
		"ItemId": 10007,
		"MinStack": 1,
		"MaxStack": 3,
		"Chance": 0.5
	},
	"4": {
		"ItemId": 10006,
		"MinStack": 1,
		"MaxStack": 4,
		"Chance": 0.5
	},
	"5": {
		"ItemId": 10024,
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
		"ItemId": 10003,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"8": {
		"ItemId": 10004,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"9": {
		"ItemId": 10005,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"10": {
		"ItemId": 10014,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"11": {
		"ItemId": 10016,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.1
	},
	"12": {
		"ItemId": 10008,
		"MinStack": 1,
		"MaxStack": 5,
		"Chance": 0.3
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
#	player.loot_item(10024, null)
#	player.loot_item(10023, null)
#	player.loot_item(10003, null)
#	player.loot_item(10004, null)
#	player.loot_item(10005, null)
#	player.loot_item(10014, null)
#	player.loot_item(10016, null)
#	player.loot_item(10023, null)
#	player.loot_item(10006, 1)
#	player.loot_item(10006, 10)
	queue_free()


