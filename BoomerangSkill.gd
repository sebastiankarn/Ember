extends RigidBody2D

var projectile_speed
var life_time = 0.2
var damage
var skill_name
var skill_range
var target

func _ready():
	skill_range = ImportData.skill_data[skill_name].SkillRange
	damage = ImportData.skill_data[skill_name].SkillDamage
	projectile_speed = ImportData.skill_data[skill_name].SkillProjectileSpeed
	var new_sprite
	if PlayerData.equipment_data["MainHand"]["Stats"] != null:
		new_sprite = get_node("/root/MainScene/Player/OnMainHandSprite").duplicate()
	else:
		new_sprite = get_node("Sprite").duplicate()
		new_sprite.show()
	new_sprite.scale = Vector2(1.3, 1.3)
	add_child(new_sprite)
	var tween = get_node("Tween")
	var tween2 = get_node("Tween2")
	var target_vector = target - position
	var new_vector = target_vector.normalized()
	var player = get_node("/root/MainScene/Player")
	new_vector *= skill_range
	if target_vector.length() > skill_range:
		target = position + new_vector
	var tween_test = get_tree().create_tween().set_loops()
	tween_test.tween_property(self, "rotation", TAU, 0.3).as_relative()
	tween.interpolate_property(self, "position", position, target, 0.5, tween.TRANS_QUAD, tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(0.5), "timeout")
	tween2.interpolate_property(self, "position", target, player.position, 0.5, tween.TRANS_QUAD, tween.EASE_IN)
	tween2.start()
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()

func _on_Spell_body_entered(body):
	if body.is_in_group("Enemies"):
		body.take_damage (damage, 0, 0, true)
