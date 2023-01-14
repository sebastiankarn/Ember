extends AnimatedSprite
var reference_map = preload("res://Sprites/Player/player_reference.map.png")
var original_color_map = preload("res://Sprites/Player/player_original_color.map.png")
var current_color_map = preload("res://Sprites/Player/player_current_color.map.png")
var test_torso = preload("res://Sprites/Player/Equipment/torso.png")
var test_legs = preload("res://Sprites/Player/Equipment/legs.png")
var animation_directions = ["down", "up", "right", "left"]
var dir_path = "res://Sprites/Player/"

# We want this to run each time something is equipped / unequipped
func _ready():
	
	update_current_map(original_color_map)
	

	#update_current_map(test_torso)

	#update_current_map(test_legs)
	
	

func update_current_map(equipment):
	var path_to_current = "res://Sprites/Player/player_current_color.map.png"
	var new_color_img = equipment.get_data()
	
	var updated_current = Image.new()
	var err = updated_current.load(path_to_current)
	
	if err != OK:
		print("Could not load correctly...")
	
	new_color_img.lock()
	updated_current.lock()
	
	var img_dims = updated_current.get_size()
	for i in range(img_dims[0]):
		for j in range(img_dims[1]):
			var new_color = new_color_img.get_pixel(i,j)
			if new_color != Color(0,0,0,0):
				updated_current.set_pixel(i,j,new_color)
	
	new_color_img.unlock()
	updated_current.unlock()
	updated_current.save_png("res://Sprites/Player/player_current_color.map.png")
	
	update_all_animation_sprites()
	

func update_all_animation_sprites():
	
	# Gets the reference dictionary to know where each color goes
	var reference_dict = get_reference_dict()
	
	# For map the new color to each animation sprite (each animation has 0 (idle), 1 and 2
	for animation_dir in animation_directions:
		for iter in range(3):

			# Example: Player/Animations/player_up_0.png
			var animation_sprite_name = dir_path + "Animations/player_" + animation_dir + "_" + str(iter) + ".png"

			# Example: Player/guy_up_0.png
			var updated_sprite_name = dir_path + "guy_" + animation_dir + "_" + str(iter) + ".png"
			
			var animation_img = Image.new()
			var err = animation_img.load(animation_sprite_name)

			var colored_img = Image.new()
			var err_2 = colored_img.load(updated_sprite_name)

			if err != OK and err_2 != OK:
				print("Failed to load...")

			animation_img.lock()
			colored_img.lock()
			
			var img_dims = animation_img.get_size()
				
			for i in range(img_dims[0]):
				for j in range(img_dims[1]):
					var color_to_change = animation_img.get_pixel(i,j)
					if color_to_change != Color(0,0,0,0) and color_to_change in reference_dict:
						colored_img.set_pixel(i,j,reference_dict[color_to_change])

			animation_img.unlock()
			colored_img.unlock()
			colored_img.save_png(updated_sprite_name)
	return 


func get_reference_dict():
	# Map of each individual pixel
	var reference_img = reference_map.get_data()

	# Map of the colors we want the character to have
	var color_img = current_color_map.get_data()
	
	# Lock the maps to be able to get and set pixel values
	reference_img.lock()
	color_img.lock()
	
	# Dimension of image (32 x 32)
	var img_dims = reference_img.get_size()

	# Dictionary used to keep track of each pixel
	var reference_dict = {}

	# Iterates through all pixels and saves the reference color as key
	# and the wanted color as the value in "reference_dict"
	for i in range(img_dims[0]):
		for j in range(img_dims[1]):
			var reference_color = reference_img.get_pixel(i,j)
			if reference_color != Color(0,0,0,0):
				var new_color = color_img.get_pixel(i,j)
				if new_color != Color(0,0,0,0):
					reference_dict[reference_color] = new_color
	
	# Unlocks the maps after editting
	reference_img.unlock()
	color_img.unlock()
	
	return reference_dict
