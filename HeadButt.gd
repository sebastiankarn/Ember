extends Area2D
var radius = 0
var skill_name
var seconds
var caster
@onready var timer = $Timer
@onready var progress_bar = $CollisionShape2D/TextureProgressBar
@onready var fire = $FireParticles
@onready var fire2 = $FireParticles2


func _ready():
	timer.start(seconds)


func _process(float) -> void:
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
		caster.isCasting = false
		caster.attacking = false
		throw_fire()


func throw_fire():
	var damage = ImportData.skill_data[skill_name].SkillDamage
	progress_bar.hide()
	fire.show()
	fire2.show()
	var targets = get_overlapping_bodies()
	var target_areas = get_overlapping_areas()
	
	for target in target_areas:
		if target.is_in_group("PlayerHitBox"):
			target.get_parent().take_damage(damage, 0, 1.5, true)
	
	await get_tree().create_timer(0.5).timeout
	queue_free()
