extends RigidBody2D

var projectile_speed
var life_time = 3
var damage
var skill_name
var skill_range

func _ready():
	#Ranged auto should not glow
	if skill_name == "10016":
		get_node("CollisionShape2D").set_deferred("disabled", true)
		get_node("PointLight2D").hide()
	skill_range = ImportData.skill_data[skill_name].SkillRange
	damage = ImportData.skill_data[skill_name].SkillDamage
	var scaled_damage = ImportData.skill_data[skill_name].Scale * PlayerData.player_stats[ImportData.skill_data[skill_name].ScaleAttribute]
	damage += scaled_damage
	projectile_speed = ImportData.skill_data[skill_name].SkillProjectileSpeed
	var skill_texture = load("res://UI_elements/skill_icons/"+ ImportData.skill_data[skill_name].SkillName + "_skill.png")
	get_node("Sprite2D").set_texture(skill_texture)
	get_node("AnimationPlayer").play(ImportData.skill_data[skill_name].SkillName)
	apply_impulse(Vector2(projectile_speed, 0).rotated(rotation), Vector2())
	SelfDestruct()
	
func SelfDestruct():
	await get_tree().create_timer(life_time + 0.3).timeout
	queue_free()

#DENNA FUNKTION Kaan tas bort
func _on_Spell_body_entered(body):
	get_node("CollisionShape2D").set_deferred("disabled", true)
	#DRAGON FIRE BALL
	if body.is_in_group("Enemies") and skill_name != "10008":
		if skill_name != "10016":
			body.take_damage (damage, 0, 0, true)
	if body.name == "Player" and skill_name == "10008":
		body.take_damage (damage, 0.3, 2, true)
		body.take_damage_over_time(250, 7, "Fire")
	if skill_name == "10008":
		var skill = load("res://RangedAOESkill.tscn")
		var skill_instance = skill.instantiate()
		skill_instance.skill_name = "10003"
		skill_instance.position = body.position
		#Location to add
		get_tree().get_root().add_child(skill_instance)
	self.hide()
	if body.name == "Player" and skill_name == "10008":
		await get_tree().create_timer(life_time).timeout
		body.get_node("Fire").visible = false


func _on_area_2d_body_entered(body):
	get_node("CollisionShape2D").set_deferred("disabled", true)
	#DRAGON FIRE BALL
	if body.is_in_group("Enemies") and skill_name != "10008":
		if skill_name != "10016":
			body.take_damage (damage, 0, 0, true)
	if body.name == "Player" and skill_name == "10008":
		body.take_damage (damage, 0.3, 2, true)
		body.take_damage_over_time(250, 7, "Fire")
	if skill_name == "10008":
		var skill = load("res://RangedAOESkill.tscn")
		var skill_instance = skill.instantiate()
		skill_instance.skill_name = "10003"
		skill_instance.position = body.position
		#Location to add
		get_tree().get_root().add_child(skill_instance)
	self.hide()
	if body.name == "Player" and skill_name == "10008":
		await get_tree().create_timer(life_time).timeout
		body.get_node("Fire").visible = false
