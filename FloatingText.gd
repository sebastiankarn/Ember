extends Marker2D

@onready var label = get_node("Label")
#@onready var tween = get_node("Tween")
var amount = 0
var type = ""

var velocity = Vector2(0, 0)
var max_size = Vector2(0.5, 0.5)

func _ready():
	if amount == -1:
		label.set_text("Block")
	else:
		label.set_text(str(amount))
	match type:
		"Heal":
			label.set("theme_override_colors/font_color", Color("2eff27"))
		"Damage":
			label.set("theme_override_colors/font_color", Color("ff3131"))
		"Critical":
			max_size = Vector2(1, 1)
			label.set("theme_override_colors/font_color", Color("f4d07a"))
		"Dodge":
			label.set("theme_override_colors/font_color", Color("ffffff"))
			label.set_text("Dodge")
		"Block":
			label.set("theme_override_colors/font_color", Color("add8e6"))
		"Mana":
			label.set("theme_override_colors/font_color", Color("00ffff"))
		"Miss":
			label.set("theme_override_colors/font_color", Color("ffffff"))
			label.set_text("Miss")
			
	randomize()
	var side_movement = randi() % 81 - 40
	velocity = Vector2(side_movement, 50)
	var tween = create_tween()
	tween.tween_property(self, 'scale', max_size, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'scale', Vector2(0.1, 0.1), 0.7).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)
	
	#tween.interpolate_property(self, 'scale', max_size, Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	#tween.start()

func _process(delta):
	position -= velocity * delta
