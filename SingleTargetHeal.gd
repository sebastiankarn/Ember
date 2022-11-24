extends Node2D

var skill_name
var heal_amount

func _ready():
	heal_amount = ImportData.skill_data[skill_name].SkillHeal
	var skill_texture = load("res://UI_elements/skill_icons/" + skill_name + "_skill.png")
	get_node("Sprite").set_texture(skill_texture)
	Heal()
	
func Heal():
	get_node("AnimationPlayer").play(skill_name)
	get_parent().OnHeal(heal_amount)
	yield(get_tree().create_timer(0.6), "timeout")
	queue_free()

