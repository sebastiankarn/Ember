extends AnimatedSprite2D
var reference_map = preload("res://Sprites/Player/player_reference.map.png").get_data()
var original_color_map = preload("res://Sprites/Player/player_original_color.map.png").get_data()
var current_color_map = original_color_map.duplicate()
var animation_directions = ["down", "up", "right", "left"]
var dir_path = "res://Sprites/Player/"
var new_frames = SpriteFrames.new()

# The images of the animations, loaded into memory
var animation_images = {}

func _ready():
	# Load the animation images into memory
	for animation_dir in animation_directions:
		for iter in range(3):
			var animation_sprite_name = dir_path + "Animations/player_" + animation_dir + "_" + str(iter) + ".png"
			animation_images[animation_sprite_name] = load(animation_sprite_name).get_data()
	update_current_map(self)

func update_current_map(animatedSprite):
	# Reset to original colors
	current_color_map = original_color_map.duplicate()
	
	# Define the order of equipment
	var body_parts = ["Feet", "Legs", "Torso", "Head"]
	
	# For each body part in order...
	for part in body_parts:
		# If the player has the equipment equipped...
		if PlayerData.equipment_data[part]["Item"] != null:
			# Get the name of the equipment
			var equipment_name = PlayerData.equipment_data[part]["Stats"]["Name"]
			# Load the image data for the equipment
			equipment_name = equipment_name.replace(" ", "_").to_lower()
			var equipment_image = load("res://Sprites/Player/Equipment/" + equipment_name + ".png").get_data()

			# Lock the images for editing
			false # equipment_image.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
			false # current_color_map.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

			var img_dims = current_color_map.get_size()
			for i in range(img_dims.x):
				for j in range(img_dims.y):
					var new_color = equipment_image.get_pixel(i, j)
					if new_color.a != 0:
						current_color_map.set_pixel(i, j, new_color)
							
			# Unlock the images after editing
			false # equipment_image.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
			false # current_color_map.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	
## Save current_color_map to a png
#	var err = current_color_map.save_png("res://debug_output.png")
#	if err != OK:
#		print("Error saving PNG: ", err)

	# After all equipment has been applied, update the animation sprites
	update_all_animation_sprites(animatedSprite)

func update_all_animation_sprites(animatedSprite):
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

		false # animation_img.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
		false # colored_img.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

		var img_dims = animation_img.get_size()

		for i in range(img_dims.x):
			for j in range(img_dims.y):
				var color_to_change = animation_img.get_pixel(i,j)
				if color_to_change.a != 0 and reference_dict.has(color_to_change):
					colored_img.set_pixel(i,j,reference_dict[color_to_change])

		false # animation_img.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
		false # colored_img.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
		
		# Convert the colored image to a texture and add it to the SpriteFrames
		var tex = ImageTexture.new()
		tex.create_from_image(colored_img)
		tex.set_filter(false)  # Disable filter
		var parts = animation_sprite_name.split("_")
		var direction = parts[parts.size()-2]
		var action_index = int(parts[parts.size()-1].get_basename())
		var action_name = "Move"
		if action_index == 0:
			action_name = "Idle"
		var animation_name = action_name + direction.capitalize()
		if !new_frames.has_animation(animation_name):
			new_frames.add_animation_library(animation_name)
			
		new_frames.add_frame(animation_name, tex)

	# Set the new SpriteFrames as the AnimatedSprite's frames
	self.frames = new_frames

func get_reference_dict():
	# Map of each individual pixel
	var reference_img = reference_map

	# Map of the colors we want the character to have
	var color_img = current_color_map

	# Lock the maps to be able to get and set pixel values
	false # reference_img.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	false # color_img.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

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
	false # reference_img.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	false # color_img.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

	return reference_dict
