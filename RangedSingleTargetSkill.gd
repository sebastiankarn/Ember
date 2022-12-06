extends RigidBody2D

var projectile_speed
var life_time = 3
var damage
var skill_name
var skill_range

func _ready():
	skill_range = ImportData.skill_data[skill_name].SkillRange
	damage = ImportData.skill_data[skill_name].SkillDamage
	projectile_speed = ImportData.skill_data[skill_name].SkillProjectileSpeed
	var skill_texture = load("res://UI_elements/skill_icons/"+ skill_name + "_skill.png")
	get_node("Sprite").set_texture(skill_texture)
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))
	SelfDestruct()
	
func SelfDestruct():
	yield(get_tree().create_timer(life_time), "timeout")
	queue_free()


func _on_Spell_body_entered(body):
	get_node("CollisionShape2D").set_deferred("disabled", true)
	if body.is_in_group("Enemies"):
		body.take_damage (damage)
	self.hide()