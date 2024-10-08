extends Node2D

var skill_name
var heal_amount

func _ready():
	heal_amount = ImportData.skill_data[skill_name].SkillHeal
	var scaled_heal = ImportData.skill_data[skill_name].Scale * PlayerData.player_stats[ImportData.skill_data[skill_name].ScaleAttribute]
	heal_amount += scaled_heal
	var skill_texture = load("res://UI_elements/skill_icons/" + ImportData.skill_data[skill_name].SkillName + "_skill.png")
	get_node("Sprite2D").set_texture(skill_texture)
	Heal()
	
func Heal():
	get_node("AnimationPlayer").play(ImportData.skill_data[skill_name].SkillName)
	get_parent().OnHeal(heal_amount)
	await get_tree().create_timer(0.6).timeout
	queue_free()
