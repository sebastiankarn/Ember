extends Camera2D
@onready var target = get_node("/root/MainScene/Player")
var loading_scene_exists = true

func _process(_delta):
	if !is_instance_valid(target):
		return
	position = target.position
