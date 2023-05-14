extends AnimatedSprite
var reference_map = preload("res://Sprites/Player/player_reference.map.png").get_data()
var original_color_map = preload("res://Sprites/Player/player_original_color.map.png").get_data()
var current_color_map = original_color_map.duplicate()
var test_torso = preload("res://Sprites/Player/Equipment/torso.png").get_data()
var test_legs = preload("res://Sprites/Player/Equipment/legs.png").get_data()
var animation_directions = ["down", "up", "right", "left"]
var dir_path = "res://Sprites/Player/"
var new_frames = SpriteFrames.new()

# The images of the animations, loaded into memory
var animation_images = {}

func _ready():
	update_current_map(original_color_map)
	update_current_map(test_torso)
	#update_current_map(test_legs)

	# Load the animation images into memory
	for animation_dir in animation_directions:
		for iter in range(3):
			var animation_sprite_name = dir_path + "Animations/player_" + animation_dir + "_" + str(iter) + ".png"
			animation_images[animation_sprite_name] = load(animation_sprite_name).get_data()

	# Apply the colors to the animations
	update_all_animation_sprites()

func update_current_map(equipment):
	var new_color_img = equipment

	new_color_img.lock()
	current_color_map.lock()

	var img_dims = current_color_map.get_size()
	for i in range(img_dims.x):
		for j in range(img_dims.y):
			var new_color = new_color_img.get_pixel(i,j)
			if new_color.a != 0:
				current_color_map.set_pixel(i,j,new_color)

	new_color_img.unlock()
	current_color_map.unlock()

	update_all_animation_sprites()


func update_all_animation_sprites():
	# Gets the reference dictionary to know where each color goes
	var reference_dict = get_reference_dict()

	# Create a new SpriteFrames resource
	var new_frames = SpriteFrames.new()

	# For each animation image...
	for animation_sprite_name in animation_images:
		# Get the image data
		var animation_img = animation_images[animation_sprite_name]
		# Create a new image for the colored version
		var colored_img = animation_img.duplicate()

		animation_img.lock()
		colored_img.lock()

		var img_dims = animation_img.get_size()

		for i in range(img_dims.x):
			for j in range(img_dims.y):
				var color_to_change = animation_img.get_pixel(i,j)
				if color_to_change.a != 0 and reference_dict.has(color_to_change):
					colored_img.set_pixel(i,j,reference_dict[color_to_change])

		animation_img.unlock()
		colored_img.unlock()
		
		# Convert the colored image to a texture and add it to the SpriteFrames
		var tex = ImageTexture.new()
		tex.create_from_image(colored_img)
		tex.flags = tex.flags & ~int(Texture.FLAG_FILTER)  # Disable filter
		var parts = animation_sprite_name.split("_")
		var direction = parts[parts.size()-2]
		var action_index = int(parts[parts.size()-1].get_basename())
		var action_name = "Move"
		if action_index == 0:
			action_name = "Idle"
		var animation_name = action_name + direction.capitalize()
		if !new_frames.has_animation(animation_name):
			new_frames.add_animation(animation_name)
		new_frames.add_frame(animation_name, tex)

	# Set the new SpriteFrames as the AnimatedSprite's frames
	self.frames = new_frames



func get_reference_dict():
	# Map of each individual pixel
	var reference_img = reference_map

	# Map of the colors we want the character to have
	var color_img = current_color_map

	# Lock the maps to be able to get and set pixel values
	reference_img.lock()
	color_img.lock()

	# Dimension of image (32 x 32)
	var img_dims = reference_img.get_size()

	# Dictionary used to keep track of each pixel
	var reference_dict = {}

	# Iterates through all pixels and saves the reference color as key
	# and the wanted color as the value in "reference_dict"
	for i in range(img_dims.x):	
		for j in range(img_dims.y):
			var reference_color = reference_img.get_pixel(i,j)
			if reference_color.a != 0:
				var new_color = color_img.get_pixel(i,j)
				if new_color.a != 0:
					reference_dict[reference_color] = new_color

	# Unlocks the maps after editing
	reference_img.unlock()
	color_img.unlock()

	return reference_dict

