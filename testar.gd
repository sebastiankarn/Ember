extends AnimatedSprite
var reference_map = preload("res://Sprites/Player/player_reference.map.png")
var color_map = preload("res://Sprites/Player/player_color.map.png")
var down_1 = preload("res://Sprites/Player/Animations/player_down_1.png")
var current_sprite = preload("res://Sprites/Player/player_current.png")

# We want this to run each time something is equipped / unequipped
func _ready():
	var animation_directions = ["down", "up", "right", "left"]
	var dir_path = "res://Sprites/Player/"
	for animation_dir in animation_directions:
		for iter in range(3):
			
			# Example: Animations/player_up_0.png
			var animation_sprite_name = dir_path + "Animations/player_" + animation_dir + "_" + str(iter) + ".png"
			
			# Example: guy_up_0.png
			var updated_sprite_name = dir_path + "/guy_" + animation_dir + "_" + str(iter) + ".png"
			
			
			var animation_img = Image.new()
			var err = animation_img.load(animation_sprite_name)
			
			if err != OK:
				print("failed...")
			
			animation_img.lock()
			
			for i in range(32):
				for j in range(32):
					var test_color = animation_img.get_pixel(i,j)
					if test_color != Color(0,0,0,0):
						print(test_color)
			
			animation_img.unlock()
			# # # #AVKODA BARA NÄR JAG SKA KÖRA# # # #
			#new_img.save_png(updated_sprite_name)
#	# Map of each individual pixel
#	var reference_img = reference_map.get_data()
#
#	# Map of the colors we want the character to have
#	var color_img = color_map.get_data()
#
#	# What will be the current sprite
#	var new_img = current_sprite.get_data()
#
#	# Example of sprite that we want to change colors of
#	var animated_img = down_1.get_data()
#
#	# Lock the images to be able to get and set pixel values
#	reference_img.lock()
#	color_img.lock()
#	new_img.lock()
#	animated_img.lock()
#
#	# Dimension of image (32 x 32)
#	var img_dims = reference_img.get_size()
#
#	# Dictionary used to keep track of each pixel
#	var reference_dict = {}
#
#	# Iterates through all pixels and saves the reference color as key
#	# and the wanted color as the value in "reference_dict"
#	for i in range(img_dims[0]):
#		for j in range(img_dims[1]):
#			var reference_color = reference_img.get_pixel(i,j)
#			if reference_color != Color(0,0,0,0):
#				var new_color = color_img.get_pixel(i,j)
#				reference_dict[reference_color] = new_color
#
#	# Iterates through all pixels of output image, and colors each
#	# pixel with its respective new color
#	for i in range(img_dims[0]):
#		for j in range(img_dims[1]):
#			var color_to_change = animated_img.get_pixel(i,j)
#			if color_to_change in reference_dict:
#				new_img.set_pixel(i,j,reference_dict[color_to_change])
#
#	# Unlocks all images after editting
#	reference_img.unlock()
#	color_img.unlock()
#	new_img.unlock()
#	animated_img.unlock()
#
#	# Saves new img for the current player sprite
#	new_img.save_png("res://Sprites/Player/player_current.png")

