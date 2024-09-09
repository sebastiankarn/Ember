extends Camera2D
@onready var target = get_node("/root/MainScene/Player")

func _process(_delta):
	if !is_instance_valid(target):
		return
	position = target.position
