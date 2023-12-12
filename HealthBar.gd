extends Control

@onready var health_bar = get_node("VBoxContainer/TextureRect/HBoxContainer/VBoxContainer/HealthBar")
@onready var mana_bar = get_node("VBoxContainer/TextureRect/HBoxContainer/VBoxContainer/ManaBar")
@onready var label : Label = get_node("VBoxContainer/Name")

func _ready():
	label.text = get_parent().user_name

func _on_health_updated(curHp, maxHp):
	var after_value = (float(100) / maxHp) * curHp
	tween_progressbar(health_bar, after_value)
	
func _on_mana_updated(curMana, maxMana):
	var after_value = (float(100) / maxMana) * curMana
	tween_progressbar(mana_bar, after_value)

func tween_progressbar(progress_bar, after_value):
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", after_value, 0.2)#set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
