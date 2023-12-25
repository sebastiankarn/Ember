extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	print_animation_references()


func print_animation_references():
	for animation_name in $AnimationPlayer.get_animation_list():
		var animation = $AnimationPlayer.get_animation(animation_name)
		for track_idx in range(animation.get_track_count()):
			var track_type = animation.track_get_type(track_idx)
			var track_path = animation.track_get_path(track_idx)

			print("Animation:", animation_name, "Track:", track_idx, "Type:", track_type, "Path:", track_path)

			if track_type == Animation.TYPE_VALUE:
				print("hello world")
					# Further inspect value tracks, e.g., for textures
					# ...



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
