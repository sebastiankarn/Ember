extends Area2D

var skill_name
var damage
var damage_delay_time
var remove_delay_time

func _ready():
	damage = ImportData.skill_data[skill_name].SkillDamage
	var scaled_damage = ImportData.skill_data[skill_name].Scale * PlayerData.player_stats[ImportData.skill_data[skill_name].ScaleAttribute]
	damage += scaled_damage
	damage_delay_time = ImportData.skill_data[skill_name].SkillDamageDelayTime
	remove_delay_time = ImportData.skill_data[skill_name].SkillRemoveDelayTime
	get_node("CollisionShape2D").get_shape().radius = ImportData.skill_data[skill_name].SkillRadius
	var skill_texture = load("res://UI_elements/skill_icons/Fire Ring_skill.png")
	get_node("Sprite").set_texture(skill_texture)
		
	AOEAttack()

func AOEAttack():
	get_node("AnimationPlayer").play("Fire Ring")
	yield(get_tree().create_timer(damage_delay_time), "timeout")
	var targets = get_overlapping_bodies()
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(damage, 0, 0, true)
	yield(get_tree().create_timer(remove_delay_time), "timeout")
	self.queue_free()
