extends CanvasLayer

const target_scene_path = "res://MainScene.tscn"

var loading_status : int
var progress : Array[float]
var waitingForMainLoading: bool = false

@onready var progress_bar : ProgressBar = $NinePatchRect/NinePatchRect/HBoxContainer/ProgressBar

func _ready() -> void:
	# Request to load the target scene:
	ResourceLoader.load_threaded_request(target_scene_path)

func _process(_delta: float) -> void:
	if !waitingForMainLoading:
		# Update the status:
		loading_status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)

		# Check the loading status:
		match loading_status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				progress_bar.value = progress[0] * 100 # Change the ProgressBar value
			ResourceLoader.THREAD_LOAD_LOADED:
				progress_bar.value = 100
				var main_scene = ResourceLoader.load_threaded_get(target_scene_path)
				var main_scene_instance = main_scene.instantiate()
				get_tree().root.add_child(main_scene_instance)
				waitingForMainLoading = true
			ResourceLoader.THREAD_LOAD_FAILED:
				# Some error happend:
				print("Error. Could not load Resource")

func main_scene_loaded():
	var main_scene = get_parent().get_node("/root/MainScene")
	get_tree().set_current_scene(main_scene)
	get_parent().remove_child(self)
	self.call_deferred("free")
