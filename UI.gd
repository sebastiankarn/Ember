extends Control

onready var levelText : Label = get_node("BG/LevelBG/LevelText")
onready var healthBar : TextureProgress = get_node("BG/HealthBar")
onready var healthBarLabel : Label = get_node("BG/HealthBar/Label")
onready var manaBar : TextureProgress = get_node("BG/ManaBar")
onready var manaBarLabel : Label = get_node("BG/ManaBar/Label")
onready var xpBar : TextureProgress = get_node("BG/XpBar")
onready var goldText : Label = get_node("BG/GoldText")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# updates the level text Label node
func update_level_text (level):
	levelText.text = str(level)
	
# updates the health bar TextureProgress value
func update_health_bar (curHp, maxHp):
	healthBar.value = (float(100) / maxHp) * curHp
	healthBarLabel.set_text(str(curHp) + "/" + str(maxHp))
	
func update_mana_bar (curMana, maxMana):
	manaBar.value = (float(100) / maxMana) * curMana
	manaBarLabel.set_text(str(curMana) + "/" + str(maxMana))
	
# updates the xp bar TextureProgress value
func update_xp_bar (curXp, xpToNextLevel):
	xpBar.value = (float(100) / xpToNextLevel) * curXp
	
# updates the gold text Label node
func update_gold_text (gold):
	goldText.text = "Gold: " + str(gold)
