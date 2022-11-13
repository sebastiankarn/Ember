extends Area2D
export var goldToGive : int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_interact (player):
	player.give_gold(goldToGive)
	queue_free()
