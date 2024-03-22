extends EnemyClass
var canThrowFireBeam = true
var isThrowingFireBeam = false

func _physics_process(_delta):
	if isThrowingFireBeam:
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
	if canThrowFireBeam and target.position.distance_to(position) < ImportData.skill_data["10017"].SkillRange:
		canThrowFireBeam = false
		get_node("TurnAxis").rotation = get_angle_to(target.get_global_position())
		var skill = load("res://DragonBeam.tscn")
		var skill_instance = skill.instantiate()
		skill_instance.skill_name = "10017"
		skill_instance.caster = self
		skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
		skill_instance.rotation = get_angle_to(target.get_global_position())
		skill_instance.seconds = 2
		isThrowingFireBeam = true
		get_parent().add_child(skill_instance)
		await get_tree().create_timer(6).timeout
		canThrowFireBeam = true
	
	super.handle_skills()
