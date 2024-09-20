extends EnemyClass
var canCast = true
var isCasting = false
@onready var fire_particles = $FireParticles

func _physics_process(_delta):
	if isCasting:
		vel = Vector2.ZERO
		return
	else:
		super._physics_process(_delta)

func handle_skills():
	if !is_instance_valid(target):
		return
	if dying or attacking:
		return
	if canCast and target.position.distance_to(position) < ImportData.skill_data["10019"].SkillRange:
		canCast = false
		isCasting = true
		var spell_to_throw = roll_ability()
		if spell_to_throw == "Charge":
			charge_ability()
			await get_tree().create_timer(6).timeout
		elif spell_to_throw == "HeadButt":
			butt_ability()
			await get_tree().create_timer(10).timeout
		canCast = true
	super.handle_skills()

func roll_ability():
	var random_float = randf()
	if random_float <= 0.5:
		return "Charge"
	else:
		return "Charge"

func charge_ability():
	isCasting = true
	get_node("TurnAxis").rotation = get_angle_to(target.get_global_position())
	var skill = load("res://BisonCharge.tscn")
	var skill_instance = skill.instantiate()
	skill_instance.skill_name = "10019"
	skill_instance.caster = self
	skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
	skill_instance.rotation = get_angle_to(target.get_global_position())
	skill_instance.seconds = 2
	get_parent().add_child(skill_instance)

func butt_ability():
	get_node("TurnAxis").rotation = get_angle_to(target.get_global_position())
	var skill = load("res://HeadButt.tscn")
	var skill_instance = skill.instantiate()
	skill_instance.skill_name = "10020"
	skill_instance.caster = self
	skill_instance.position = target.get_global_position()
	skill_instance.seconds = 1.5
	get_parent().add_child(skill_instance)

# Override start_attack_animation
func start_attack_animation():
	if attacking or isCasting or position.distance_to(target.position) >= attackDist:
		return  # Prevent attacking while casting
	else:
		attacking = true
		if facingDir.x > 0:
			play_animation("hit_right")
		else:
			play_animation("hit_left")

# Override _on_Timer_timeout
func _on_Timer_timeout():
	if !is_instance_valid(target):
		return
	if isCasting:
		return  # Prevent attacking while casting
	if position.distance_to(target.position) <= attackDist:
		start_attack_animation()
