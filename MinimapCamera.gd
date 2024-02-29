extends Camera2D
@onready var target = get_node("/root/MainScene/Player")

func _process(_delta):
	if !is_instance_valid(target):
		return
	global_position = target.global_position
	print(global_position)
