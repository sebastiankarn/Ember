extends Control

onready var health_bar : ProgressBar = get_node("HealthBar")
onready var mana_bar : ProgressBar = get_node("ManaBar")
onready var label : Label = get_node("Name")

func _ready():
	label.text = get_parent().user_name

func _on_health_updated(curHp, maxHp):
	health_bar.value = (float(100) / maxHp) * curHp

func _on_mana_updated(curMana, maxMana):
	mana_bar.value = (float(100) / maxMana) * curMana
