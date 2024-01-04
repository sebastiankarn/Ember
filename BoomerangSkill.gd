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
	var scaled_damage = ImportData.skill_data[skill_name].Scale * PlayerData.player_stats[ImportData.skill_data[skill_name].ScaleAttribute]
	damage += scaled_damage
	projectile_speed = ImportData.skill_data[skill_name].SkillProjectileSpeed
	var new_sprite
	if PlayerData.equipment_data["MainHand"]["Stats"] != null:
		new_sprite = get_node("/root/MainScene/Player/OnMainHandSprite").duplicate()
	else:
		new_sprite = get_node("Sprite2D").duplicate()
		new_sprite.show()
	new_sprite.scale = Vector2(1.3, 1.3)
	add_child(new_sprite)
	var tween = create_tween()
	var target_vector = target - position
	var new_vector = target_vector.normalized()
	var player = get_node("/root/MainScene/Player")
	new_vector *= skill_range
	if target_vector.length() > skill_range:
		target = position + new_vector
	var tween3 = create_tween().set_loops()
	tween3.tween_property(self, "rotation", TAU, 0.3).as_relative()
	tween.tween_property(self, "position", target, 0.5).set_trans(tween.TRANS_QUAD).set_ease(tween.EASE_OUT)
	tween.tween_property(self, "position", player.position, 0.5).set_trans(tween.TRANS_QUAD).set_ease(tween.EASE_IN)
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_Spell_body_entered(body):
	return
	if body.is_in_group("Enemies"):
		body.take_damage(damage, 0, 0, true)


func _on_area_2d_body_entered(body):
	if body.is_in_group("Enemies"):
		body.take_damage(damage, 0, 0, true)
