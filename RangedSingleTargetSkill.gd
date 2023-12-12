extends RigidBody2D

var projectile_speed
var life_time = 0.2
var damage
var skill_name
var skill_range

func _ready():
	skill_range = ImportData.skill_data[skill_name].SkillRange
	damage = ImportData.skill_data[skill_name].SkillDamage
	var scaled_damage = ImportData.skill_data[skill_name].Scale * PlayerData.player_stats[ImportData.skill_data[skill_name].ScaleAttribute]
	damage += scaled_damage
	if skill_name == '10001' and get_node("/root/MainScene/Player").skill_2A:
		get_node("PointLight2D").show()
		damage += 3
	projectile_speed = ImportData.skill_data[skill_name].SkillProjectileSpeed
	var skill_texture = load("res://UI_elements/skill_icons/"+ ImportData.skill_data[skill_name].SkillName + "_skill.png")
	get_node("Sprite2D").set_texture(skill_texture)
	#get_node("AnimationPlayer").play(ImportData.skill_data[skill_name].SkillName)
	apply_impulse(Vector2(projectile_speed, 0).rotated(rotation), Vector2())
	SelfDestruct()
	
func SelfDestruct():
	await get_tree().create_timer(life_time).timeout
	queue_free()


func _on_Spell_body_entered(body):
	get_node("CollisionShape2D").set_deferred("disabled", true)
	if body.is_in_group("Enemies"):
		body.take_damage (damage, 0, 0, true)
	self.hide()
