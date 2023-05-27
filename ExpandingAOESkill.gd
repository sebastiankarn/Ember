extends Area2D

var skill_name
var damage
var radius
var remove_delay_time
var expansion_time
var damaged_targets = []

var circle_shape = preload("res://Resources/CircleShape.res")

func _ready():
	damage = ImportData.skill_data[skill_name].SkillDamage
	radius = ImportData.skill_data[skill_name].SkillRadius
	expansion_time = ImportData.skill_data[skill_name].SkillExpansionTime
	var skill_texture = load("res://UI_elements/skill_icons/" + ImportData.skill_data[skill_name].SkillName + "_skill.png")
	get_node("Sprite").set_texture(skill_texture)
		
	AOEAttack()

func AOEAttack():
	get_node("AnimationPlayer").play(ImportData.skill_data[skill_name].SkillName)
	var radius_step = radius / (expansion_time / 0.05)
	while get_node("CollisionShape2D").get_shape().radius <= radius:
		var shape = circle_shape.duplicate()
		shape.set_radius(get_node("CollisionShape2D").get_shape().radius + radius_step)
		get_node("CollisionShape2D").set_shape(shape)
		var targets = get_overlapping_bodies()
		for target in targets:
			if damaged_targets.has(target):
				continue
			else:
				target.take_damage(damage, 0, 0, true)
				damaged_targets.append(target)
		yield(get_tree().create_timer(0.05), "timeout")
		continue
	queue_free()
