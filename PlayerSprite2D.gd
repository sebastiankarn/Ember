extends Sprite2D

# Add textures for legs, feet, torso and head (that way helmet appears on top of torso, etc.)
var body_parts = ["Back", "Legs", "Feet", "Torso", "Head", "Hands", "Back"]
var base_animation_texture = preload("res://Sprites/Player/Equipment/player_animation_base.png")

func _ready():
	update_animation_sprites()

func update_animation_sprites():
	# Base of new image is base animations, player without anything equipped
	var updated_image = base_animation_texture.get_image()
	var back_behind_rendered = false
	for body_part in body_parts:
		if PlayerData.equipment_data[body_part]["Item"] != null:
			var equipment_name = PlayerData.equipment_data[body_part]["Stats"]["Name"]
			equipment_name = equipment_name.replace(" ", "_").to_lower()
			if equipment_name != "cape":
				add_texture(equipment_name, updated_image)
			else:
				if not back_behind_rendered:
					add_texture("cape_behind", updated_image)
					back_behind_rendered = true
					add_texture("base_anim", updated_image)
				else:
					add_texture("cape_front", updated_image)

	var updated_texture = ImageTexture.create_from_image(updated_image)
	self.texture = updated_texture


func add_texture(equipment_name, updated_image):
	var equipment_texture = Texture2D
	if equipment_name == "base_anim":
		equipment_texture = base_animation_texture
	# Add texture of equpment on top of updated_image
	else:
		equipment_texture = load("res://Sprites/Player/Equipment/" + equipment_name + ".png")
	var equipment_image = equipment_texture.get_image()

	for x in range(equipment_image.get_width()):
		for y in range(equipment_image.get_height()):
			var equipment_pixel = equipment_image.get_pixel(x, y)
			if equipment_pixel.a > 0.0:  # If not fully transparent
				updated_image.set_pixel(x, y, equipment_pixel)
