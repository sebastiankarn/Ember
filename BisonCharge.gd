extends Area2D
var radius = 0
var skill_name
var seconds
var caster
@onready var timer = $Timer
@onready var progress_bar = $CollisionShape2D/TextureProgressBar
@onready var ray_cast = $RayCast2D

func _ready():
	var animation_player = caster.get_node("AnimationPlayer")
	var current_animation = animation_player.current_animation
	if current_animation.ends_with("right"):
		caster.play_animation("precharge_right")
	else:
		caster.play_animation("precharge_left")
	timer.start(seconds)

func _process(_delta: float) -> void:
	var time_left = timer.time_left
	var progress_bar_value
	if time_left > 0:
		progress_bar_value = 100 - (((timer.time_left) * 100)/seconds)
	else:
		progress_bar_value = 100
	progress_bar.value = progress_bar_value

func _on_timer_timeout():
	if caster == null:
		queue_free()
	else:
		charge()

func charge():
	var skill_range = ray_cast.target_position.length()
	var target_vector = Vector2(cos(rotation), sin(rotation))
	var new_vector = target_vector.normalized()
	new_vector *= skill_range
	var end_location = position + new_vector
	if ray_cast.is_colliding():
		if "Tile" in str(ray_cast.get_collider()):
			end_location = ray_cast.get_collision_point()
	var damage = ImportData.skill_data[skill_name].SkillDamage
	progress_bar.hide()
	var target_areas = get_overlapping_areas()
	
	for target in target_areas:
		if target.is_in_group("PlayerHitBox"):
			target.get_parent().take_damage(damage, 0, 1.5, true)
			var stun_duration = 2
			target.get_parent().stun(stun_duration)
	
	# Determine the facing direction and play the appropriate charge animation
	var animation_player = caster.get_node("AnimationPlayer")
	var current_animation = animation_player.current_animation
	if target_vector.x > 0:
		caster.play_animation("charge_right")
	else:
		caster.play_animation("charge_left")
	
	var tween = create_tween()
	tween.tween_property(caster, "position", end_location, 0.2).set_trans(tween.TRANS_CUBIC).set_ease(tween.EASE_IN)
	await get_tree().create_timer(0.2).timeout
	if caster != null:
		caster.isCasting = false
		caster.attacking = false
	queue_free()
