extends Area2D
@onready var loot_list = get_node("/root/MainScene/CanvasLayer/LootList")
var monster_name = "Chest"
@onready var player = get_node("/root/MainScene/Player")

var wolf_data = {
	"0":{
	  "ItemId":10002,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "1":{
	  "ItemId":10033,
	  "MinStack":1,
	  "MaxStack":1,
	  "Chance":0.3
   },
   "2":{
	  "ItemId":10008,
	  "MinStack":2,
	  "MaxStack":4,
	  "Chance":0.3
   },
   "3":{
	  "ItemId":10001,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "4":{
	  "ItemId":10034,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "5":{
	  "ItemId":10010,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "6":{
	  "ItemId":10024,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "7":{
	  "ItemId":10025,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   }
}

var minotaur_data = {
   "0":{
	  "ItemId":10032,
	  "MinStack":1,
	  "MaxStack":1,
	  "Chance":0.3
   },
   "1":{
	  "ItemId":10008,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "2":{
	  "ItemId":10031,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "3":{
	  "ItemId":10023,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "4":{
	  "ItemId":10034,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "5":{
	  "ItemId":10035,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "6":{
	  "ItemId":10036,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "7":{
	  "ItemId":10009,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "8":{
	  "ItemId":10010,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "9":{
	  "ItemId":10011,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "10":{
	  "ItemId":10008,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.25
   },
   "11":{
	  "ItemId":10025,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.25
   }
}

var shaman_data = {
   "0":{
	  "ItemId":10032,
	  "MinStack":1,
	  "MaxStack":1,
	  "Chance":0.3
   },
   "1":{
	  "ItemId":10003,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "2":{
	  "ItemId":10004,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "3":{
	  "ItemId":10037,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "4":{
	  "ItemId":10013,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "5":{
	  "ItemId":10015,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "6":{
	  "ItemId":10017,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "7":{
	  "ItemId":10019,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "8":{
	  "ItemId":10021,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "9":{
	  "ItemId":10011,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "10":{
	  "ItemId":10008,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   },
   "11":{
	  "ItemId":10025,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   },
   "12":{
	  "ItemId":10006,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   },
   "13":{
	  "ItemId":10007,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   }
}

var dragon_data = {
   "0":{
	  "ItemId":10030,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "1":{
	  "ItemId":10029,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.1
   },
   "2":{
	  "ItemId":10026,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.1
   },
   "3":{
	  "ItemId":10027,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "4":{
	  "ItemId":10028,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "5":{
	  "ItemId":10037,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "6":{
	  "ItemId":10013,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "7":{
	  "ItemId":10015,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "8":{
	  "ItemId":10017,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "9":{
	  "ItemId":10019,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "10":{
	  "ItemId":10021,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "11":{
	  "ItemId":10012,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "12":{
	  "ItemId":10008,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   },
   "13":{
	  "ItemId":10025,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   },
   "14":{
	  "ItemId":10006,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   },
   "15":{
	  "ItemId":10007,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   }
}

var bison_data = {
   "0":{
	  "ItemId":10003,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "1":{
	  "ItemId":10004,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "2":{
	  "ItemId":10030,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "3":{
	  "ItemId":10027,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "4":{
	  "ItemId":10028,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "5":{
	  "ItemId":10037,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "6":{
	  "ItemId":10013,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "7":{
	  "ItemId":10015,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "8":{
	  "ItemId":10017,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "9":{
	  "ItemId":10019,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "10":{
	  "ItemId":10021,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "11":{
	  "ItemId":10012,
	  "MinStack":null,
	  "MaxStack":null,
	  "Chance":0.05
   },
   "12":{
	  "ItemId":10008,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   },
   "13":{
	  "ItemId":10025,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   },
   "14":{
	  "ItemId":10006,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
   },
   "15":{
	  "ItemId":10007,
	  "MinStack":2,
	  "MaxStack":3,
	  "Chance":0.3
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
		"ItemId": 10001,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	},
	"1": {
		"ItemId": 10008,
		"MinStack": 5,
		"MaxStack": 5,
		"Chance": 1
	},
	"2": {
		"ItemId": 10037,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	}
}

var default_data = {
	"0": {
		"ItemId": 10008,
		"MinStack": 5,
		"MaxStack": 5,
		"Chance": 1
	},
	"1": {
		"ItemId": 10037,
		"MinStack": null,
		"MaxStack": null,
		"Chance": 1
	}
}

var goldToGive = {
	"Bison": {
		"Min": 500,
		"Max": 800
	},

	"Dragon": {
		"Min": 700,
		"Max": 970
	},

	"Skeleton": {
		"Min": 10,
		"Max": 30
	},

	"Wolf": {
		"Min": 70,
		"Max": 170
	},

	"Minotaur": {
		"Min": 70,
		"Max": 170
	},

	"Shaman": {
		"Min": 100,
		"Max": 600
	},

	"Chest": {
		"Min": 10,
		"Max": 30
	}
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	var dist = position.distance_to(player.position)
	if dist < 85:
		get_node("LightOccluder2D").hide()
	else:
		get_node("LightOccluder2D").show()

func on_interact(player_node):
	var inventory_full = true
	for inventory_item in PlayerData.inv_data.keys():
		if PlayerData.inv_data[inventory_item]["Item"] == null:
			inventory_full = false
	if inventory_full:
		print("BACKPACK IS FULL")
		return
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
				player_node.loot_item(data[str(i)]["ItemId"], stack)
				loot_list.fill_loot_list(str(data[str(i)]["ItemId"]), stack)
		#Inte stackable
		else:
			if randf() <= chance:
				player_node.loot_item(get_tree().get_current_scene().ItemGeneration(data[str(i)]["ItemId"], true), stack)
				loot_list.fill_loot_list(str(data[str(i)]["ItemId"]), stack)
	rng.randomize()
	var gold_amount = 10
	if goldToGive.has(monster_name):
		gold_amount = rng.randi_range(goldToGive[monster_name]["Min"], goldToGive[monster_name]["Max"])
	player_node.give_gold(gold_amount)
	loot_list.fill_loot_list("Gold", gold_amount)
	queue_free()

func set_loot(loot_name):
	if loot_name == "Skeleton":
		data = skeleton_data

	elif loot_name == "Dragon":
		data = dragon_data

	elif loot_name == "Wolf":
		data = wolf_data

	elif loot_name == "Minotaur":
		data = minotaur_data

	elif loot_name == "Shaman":
		data = shaman_data

	elif loot_name == "Bison":
		data = bison_data

	else:
		data = default_data

	monster_name = loot_name

func on_save_game(saved_data:Array[SavedData]):
	var my_data = SavedChestData.new()
	my_data.position = global_position
	my_data.scene_path = scene_file_path
	my_data.monster_name = monster_name
	my_data.loot_data = data

	saved_data.append(my_data)

func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()

func on_load_game(saved_data:SavedData):
	var my_data:SavedChestData = saved_data as SavedChestData
	global_position = my_data.position
	monster_name = my_data.monster_name
	data = my_data.loot_data
