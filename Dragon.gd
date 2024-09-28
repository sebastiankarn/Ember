extends EnemyClass
var canThrowFire = true
var isThrowingFire = false
@onready var fire_particles = $FireParticles
@onready var pointlight2d = $PointLight2D


func _physics_process(_delta):
	if isThrowingFire:
		vel = Vector2.ZERO
		manage_animations()
		return
	else:
		super._physics_process(_delta)


func handle_skills():
	if !is_instance_valid(target):
		return
	if dying or attacking:
		return
	if canThrowFire and is_aggroed and target.position.distance_to(position) < ImportData.skill_data["10017"].SkillRange:
		canThrowFire = false
		isThrowingFire = true
		var spell_to_throw = roll_fire_spell()
		if spell_to_throw == "DragonBeam":
			throw_dragon_beam()
			await get_tree().create_timer(6).timeout
		elif spell_to_throw == "DragonJump":
			throw_dragon_jump()
			await get_tree().create_timer(10).timeout
		canThrowFire = true

	super.handle_skills()


func roll_fire_spell():
	var random_float = randf()
	if random_float <= 0.5:
		return "DragonBeam"
	else:
		return "DragonJump"


func throw_dragon_beam():
	get_node("TurnAxis").rotation = get_angle_to(target.get_global_position())
	var skill = load("res://DragonBeam.tscn")
	var skill_instance = skill.instantiate()
	skill_instance.skill_name = "10017"
	skill_instance.caster = self
	skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
	skill_instance.rotation = get_angle_to(target.get_global_position())
	skill_instance.seconds = 2
	get_parent().add_child(skill_instance)


func throw_dragon_jump():
	get_node("TurnAxis").rotation = get_angle_to(target.get_global_position())
	var skill = load("res://DragonJump.tscn")
	var skill_instance = skill.instantiate()
	skill_instance.skill_name = "10018"
	skill_instance.caster = self
	skill_instance.position = target.get_global_position()
	skill_instance.seconds = 1.5
	get_parent().add_child(skill_instance)

func buff_the_dragon():
	#BEFORE BUFF
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(10,0.3,0.3), 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	var old_attack_rate = attackRate
	var new_attack_rate = old_attack_rate/5
	var old_attack = attack
	var new_attack = old_attack*2
	var old_move_speed = moveSpeed
	var new_move_speed = moveSpeed*5
	set_attack_rate(new_attack_rate)
	attack = new_attack
	moveSpeed = new_move_speed
	fire_particles.show()
	pointlight2d.show()

	await get_tree().create_timer(4).timeout

	#AFTER BUFF
	if self:
		set_attack_rate(old_attack_rate)
		attack = old_attack
		moveSpeed = old_move_speed

		var tween2 = create_tween()
		tween2.tween_property(self, "modulate", Color(1,1,1), 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
		fire_particles.hide()
		pointlight2d.hide()
