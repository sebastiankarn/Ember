extends Control

@onready var levelText : Label = get_node("BG/LevelBG/LevelText")
@onready var healthBar : TextureProgressBar = get_node("BG/HealthBar")
@onready var healthBarLabel : Label = get_node("BG/HealthBar/Label")
@onready var manaBar : TextureProgressBar = get_node("BG/ManaBar")
@onready var manaBarLabel : Label = get_node("BG/ManaBar/Label")
@onready var xpBar : TextureProgressBar = get_node("BG/XpBar")
@onready var xpBarLabel : Label = get_node("BG/XpBar/Label")
@onready var image = get_node("BG/Image")


# Called when the node enters the scene tree for the first time.
func _ready():
	image.set_texture(load("res://AI_art/player.png"))

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
	
# updates the xp bar TextureProgress value
func update_xp_bar (curXp, xpToNextLevel):
	var after_value = (float(100) / xpToNextLevel) * curXp
	tween_progressbar(xpBar, after_value)
	xpBarLabel.set_text("(" + str(int(after_value)) + "%)" + " " + str(curXp) + "/" + str(xpToNextLevel))

func tween_progressbar(progress_bar, after_value):
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", after_value, 0.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
