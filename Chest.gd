extends Area2D
export var goldToGive : int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_interact (player):
	player.give_gold(goldToGive)
	print(PlayerData.inv_data)
	PlayerData.inv_data["Inv10"]["Item"] = "10004"
	PlayerData.inv_data["Inv10"]["Stack"] = "1"
	print(PlayerData.inv_data["Inv10"]["Item"], PlayerData.inv_data["Inv10"]["Stack"])
	queue_free()


