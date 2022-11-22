extends Control

onready var health_bar : ProgressBar = get_node("HealthBar")
onready var label : Label = get_node("Name")

func _ready():
	label.text = get_parent().user_name

func _on_health_updated(curHp, maxHp):
	health_bar.value = (100 / maxHp) * curHp
