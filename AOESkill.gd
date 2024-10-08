extends Area2D

var skill_name
var damage
var radius
var remove_delay_time
var expansion_time

var circle_shape = preload("res://Resources/CircleShape.res")

func _ready():
	damage = ImportData.skill_data[skill_name].SkillDamage
	var scaled_damage = ImportData.skill_data[skill_name].Scale * PlayerData.player_stats[ImportData.skill_data[skill_name].ScaleAttribute]
	damage += scaled_damage
	radius = ImportData.skill_data[skill_name].SkillRadius
	expansion_time = ImportData.skill_data[skill_name].SkillExpansionTime
	var skill_texture = load("res://UI_elements/skill_icons/" + ImportData.skill_data[skill_name].SkillName + "_skill.png")
	get_node("Sprite2D").set_texture(skill_texture)
	AOEAttack()
	await get_tree().create_timer(1.5).timeout
	AOEAttack()
	await get_tree().create_timer(1.5).timeout
	AOEAttack()
	await get_tree().create_timer(1.3).timeout
	queue_free()
	
func AOEAttack():
	var player = get_node("/root/MainScene/Player")
	self.position = player.position
	var damaged_targets = []
	get_node("AnimationPlayer").play(ImportData.skill_data[skill_name].SkillName)
	get_node("CollisionShape2D").get_shape().radius = 0.01
	var radius_step = radius / (expansion_time / 0.05)
	while get_node("CollisionShape2D").get_shape().radius <= radius:
		self.position = player.position
		var shape = circle_shape.duplicate()
		shape.set_radius(get_node("CollisionShape2D").get_shape().radius + radius_step)
		get_node("CollisionShape2D").set_shape(shape)
		var targets = get_overlapping_bodies()
		var target_areas = get_overlapping_areas()
		for target in targets:
			if damaged_targets.has(target):
				continue
			else:
				if target.has_method("take_damage"):
					target.take_damage(damage, 0, 0, true)
					damaged_targets.append(target)
		
		for target_area in target_areas:
			if damaged_targets.has(target_area):
				continue
			else:
				if target_area.is_in_group("SpellCollision"):
					target_area.get_parent().take_damage(damage, 0, 0, true)
					damaged_targets.append(target_area)
		await get_tree().create_timer(0.05).timeout
		continue
	get_node("AnimationPlayer").play_backwards(ImportData.skill_data[skill_name].SkillName)
	while true:
		self.position = player.position
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(0.5).timeout
