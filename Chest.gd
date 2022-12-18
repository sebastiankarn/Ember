extends Area2D
export var goldToGive : int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_interact (player):
	player.give_gold(goldToGive)
	player.loot_item(10024, null)
	player.loot_item(10023, null)
	player.loot_item(10003, null)
	player.loot_item(10004, null)
	player.loot_item(10005, null)
	player.loot_item(10014, null)
	player.loot_item(10016, null)
	player.loot_item(10023, null)
	player.loot_item(10006, 1)
	player.loot_item(10006, 10)
	queue_free()


