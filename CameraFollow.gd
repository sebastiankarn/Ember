extends Camera2D
@onready var target = get_node("/root/MainScene/Player")
var loading_scene_exists = true

func _process(_delta):
#	if loading_scene_exists and loading_scene:
#		position = loading_scene.position
#	else:
#		loading_scene_exists = false
		
	if !is_instance_valid(target):
		return
	position = target.position

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
