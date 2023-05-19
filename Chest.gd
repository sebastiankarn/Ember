extends Area2D
onready var loot_list = get_node("/root/MainScene/CanvasLayer/LootList")
var monster_name = "Chest"
var dragon_data = {
	"0": {
		"ItemId": 10003,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"1": {
		"ItemId": 10008,
		"MinStack": 3,
		"MaxStack": 5,
		"Chance": 1
	},
	"2": {
		"ItemId": 10006,
		"MinStack": 3,
		"MaxStack": 5,
		"Chance": 1
	},
	"3": {
		"ItemId": 10007,
		"MinStack": 3,
		"MaxStack": 5,
		"Chance": 1
	},
	"4": {
		"ItemId": 10025,
		"MinStack": 2,
		"MaxStack": 3,
		"Chance": 1
	},
	"5": {
		"ItemId": 10004,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"6": {
		"ItemId": 10005,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"7": {
		"ItemId": 10012,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"8": {
		"ItemId": 10014,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"9": {
		"ItemId": 10016,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"10": {
		"ItemId": 10018,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.06
	},
	"11": {
		"ItemId": 10020,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"12": {
		"ItemId": 10022,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"13": {
		"ItemId": 10023,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	}
}

var skeleton_data = {
	"0": {
		"ItemId": 10001,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"1": {
		"ItemId": 10002,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"2": {
		"ItemId": 10005,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
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
		"ItemId": 10009,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"7": {
		"ItemId": 10010,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"8": {
		"ItemId": 10011,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"9": {
		"ItemId": 10013,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"10": {
		"ItemId": 10015,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"11": {
		"ItemId": 10017,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"12": {
		"ItemId": 10019,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"13": {
		"ItemId": 10021,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"14": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 0.05
	},
	"15": {
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
	},
	"4": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"5": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"6": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"7": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"8": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"9": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"10": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"11": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"12": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"13": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"14": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"15": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"16": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"17": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"18": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"19": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"20": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"22": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"23": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"24": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"25": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"26": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"27": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"28": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"29": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"30": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"31": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"32": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"33": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"34": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"35": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"36": {
		"ItemId": 10024,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"37": {
		"ItemId": 10003,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	}
}

var goldToGive = {
	"Dragon": {
		"Min": 70,
		"Max": 170
	},
	"Skeleton": {
		"Min": 10,
		"Max": 30
	},
	"Chest": {
		"Min": 10,
		"Max": 30
	}
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_interact (player):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomize()
	for i in data.keys():
		var chance = data[str(i)]["Chance"]
		var stack = null
		rng.randomize()
		#Stackable
		if data[str(i)]["MinStack"] != null:
			stack = rng.randi_range(data[str(i)]["MinStack"], data[str(i)]["MaxStack"])
			if randf() <= chance:
				player.loot_item(data[str(i)]["ItemId"], stack)
				loot_list.fill_loot_list(str(data[str(i)]["ItemId"]), stack)
		#Inte stackable
		else:
			if randf() <= chance:
				player.loot_item(get_tree().get_current_scene().ItemGeneration(data[str(i)]["ItemId"], true), stack)
				loot_list.fill_loot_list(str(data[str(i)]["ItemId"]), stack)
	rng.randomize()
	var gold_amount = rng.randi_range(goldToGive[monster_name]["Min"], goldToGive[monster_name]["Max"])
	player.give_gold(gold_amount)
	loot_list.fill_loot_list("Gold", gold_amount)
	queue_free()

func set_loot(name):
	if name == "Skeleton":
		data = skeleton_data
		
	if name == "Dragon":
		data = dragon_data
	
	monster_name = name
	
