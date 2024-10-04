extends Camera2D

@onready var target = get_node("/root/MainScene/Player")
@onready var player_dot = $"../PlayerDot"
@onready var npc_dots = $"../Npcs"
@onready var enemy_dots = $"../Enemies"

func _process(_delta):
	if !is_instance_valid(target):
		return
	position = target.position
	player_dot.position = target.position
	player_dot.scale = Vector2(10, 10)
	remove_all_children(npc_dots)
	remove_all_children(enemy_dots)
	handle_npc_positions()
	handle_enemy_positions()

func handle_npc_positions():
	var npcs = get_tree().get_nodes_in_group("Npc")
	for npc in npcs:
		var npc_dot = load("res://NpcDot.tscn")
		var npc_dot_instance = npc_dot.instantiate()
		npc_dot_instance.position = npc.position
		npc_dot_instance.scale = Vector2(10, 10)
		var quest_mark = npc.get_node("ExclamationMark")
		if quest_mark.visible:
			npc_dot_instance.set_texture(quest_mark.get_node("TextureRect").texture)
			npc_dot_instance.scale = Vector2(5, 5)
		npc_dots.add_child(npc_dot_instance)

func handle_enemy_positions():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		var enemy_dot = load("res://EnemyDot.tscn")
		var enemy_dot_instance = enemy_dot.instantiate()
		enemy_dot_instance.position = enemy.position
		enemy_dot_instance.scale = Vector2(10, 10)
		enemy_dots.add_child(enemy_dot_instance)

func remove_all_children(node):
	for N in node.get_children():
		N.queue_free()
