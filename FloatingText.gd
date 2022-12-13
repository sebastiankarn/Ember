extends Position2D

onready var label = get_node("Label")
onready var tween = get_node("Tween")
var amount = 0
var type = ""

var velocity = Vector2(0, 0)
var max_size = Vector2(0.5, 0.5)

func _ready():
	print("HIT")
	print(type)
	label.set_text(str(amount))
	match type:
		"Heal":
			label.set("custom_colors/font_color", Color("2eff27"))
		"Damage":
			label.set("custom_colors/font_color", Color("ff3131"))
		"Critical":
			max_size = Vector2(1, 1)
			label.set("custom_colors/font_color", Color("f4d07a"))
		"Dodge":
			label.set("custom_colors/font_color", Color("ffffff"))
			label.set_text("Dodge")
			print("Dodge")
		"Block":
			label.set("custom_colors/font_color", Color("add8e6"))
			label.set_text("Block")
			print("Block")
			
	randomize()
	var side_movement = randi() % 81 - 40
	velocity = Vector2(side_movement, 50)
	tween.interpolate_property(self, 'scale', scale, max_size, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', max_size, Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	tween.start()


func _on_Tween_tween_all_completed():
	self.queue_free()

func _process(delta):
	position -= velocity * delta
