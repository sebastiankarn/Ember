extends Sprite2D

var body_parts = ["Feet", "Legs", "Torso", "Head"]
var base_animation_texture = preload("res://Sprites/Player/Equipment/player_animation_base.png")
var test_texture = preload("res://Sprites/Player/player_animation_test.png")

func update_animation_sprites():

	var base_image = base_animation_texture.get_image()
	for body_part in body_parts:
		if PlayerData.equipment_data[body_part]["Item"] != null:
			var equipment_name = PlayerData.equipment_data[body_part]["Stats"]["Name"]
			equipment_name = equipment_name.replace(" ", "_").to_lower()
			var equipment_texture = load("res://Sprites/Player/Equipment/" + equipment_name + ".png")
			var equipment_image = equipment_texture.get_image()
#
			# Assuming both images are of the same dimensions
			for x in range(equipment_image.get_width()):
				for y in range(equipment_image.get_height()):
					var equipment_pixel = equipment_image.get_pixel(x, y)
					if equipment_pixel.a > 0.0:  # If not fully transparent
						base_image.set_pixel(x, y, equipment_pixel)
#
#
	## Save the updated image to a file
	base_image.save_png("res://Sprites/Player/player_animation_updated.png")
	var loaded_image = Image.load_from_file("res://Sprites/Player/player_animation_updated.png")
	var loaded_texture = ImageTexture.create_from_image(loaded_image)
	self.texture = loaded_texture

func _ready():
	update_animation_sprites()
