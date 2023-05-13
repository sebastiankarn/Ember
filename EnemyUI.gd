extends Control

onready var name_node = get_node("BG/HBoxContainer/VBoxContainer/Name")
onready var levelText : Label = get_node("BG/HBoxContainer/LevelBG/LevelText")
onready var healthBar : TextureProgress = get_node("BG/HBoxContainer/VBoxContainer/HealthBar")
onready var healthBarLabel : Label = get_node("BG/HBoxContainer/VBoxContainer/HealthBar/Label")
onready var manaBar : TextureProgress = get_node("BG/HBoxContainer/VBoxContainer/ManaBar")
onready var manaBarLabel : Label = get_node("BG/HBoxContainer/VBoxContainer/ManaBar/Label")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_ui(enemy):
	name_node.set_text(enemy.user_name)
	update_health_bar(enemy.curHp, enemy.maxHp)
	update_mana_bar(100, 100)
	show()
# updates the level text Label node
func update_level_text (level):
	levelText.text = str(level)
	
# updates the health bar TextureProgress value
func update_health_bar (curHp, maxHp):
	var after_value = (float(100) / maxHp) * curHp
	tween_progressbar(healthBar, after_value)
	healthBarLabel.set_text(str(curHp) + "/" + str(maxHp))
	
func update_mana_bar (curMana, maxMana):
	var after_value = (float(100) / maxMana) * curMana
	tween_progressbar(manaBar, after_value)
	manaBarLabel.set_text(str(curMana) + "/" + str(maxMana))

func tween_progressbar(progress_bar, after_value):
	var tween = get_tree().create_tween()
	tween.tween_property(progress_bar, "value", after_value, 0.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)