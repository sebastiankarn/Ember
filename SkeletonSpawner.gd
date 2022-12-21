extends Node2D

onready var spawnTimer := $SpawnTimer
onready var player = get_node("/root/MainScene/Player")

var next_spawn_time = 30
var preloaded_enemy = preload("res://Enemy.tscn")
var enemy

func _ready():
	spawnTimer.start(0)


func _on_SpawnTimer_timeout():
	
	if is_instance_valid(enemy) or position.distance_to(player.position) < 250:
		pass
	else:
		print("Not valid")
		enemy = preloaded_enemy.instance()
		enemy.position = position
		get_tree().get_root().add_child(enemy)
	spawnTimer.start(next_spawn_time)
