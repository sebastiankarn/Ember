extends CharacterBody2D
class_name EnemyClass

@onready var loot_box = preload("res://Chest.tscn")
@onready var SpacingArea = $SpacingArea
var floating_text = preload("res://FloatingText.tscn")
@export var user_name : String
@export var curHp : int
@export var maxHp : int
@export var moveSpeed : int
var facingDir = Vector2()
var vel = Vector2()
@export var xpToGive : int
@export var attack : int
@export var critChance : float
@export var critFactor : float
@export var blockChance : float
@export var dodgeChance : float
@export var defense: int
@export var attackRate : float
var changeDir = false
@export var attackDist : float
@export var chaseDist : float
@onready var timer = $Timer
@onready var target = get_node("/root/MainScene/Player")
@onready var anim = $AnimationPlayer
@onready var health_bar = $HealthBar
@onready var ui_health_bar = get_node("/root/MainScene/CanvasLayer/EnemyUI")
var step : int = 0
@export var canHeal : bool
@export var canThrowFireBall : bool
@export var hasSkills : bool

@export var path_to_target := NodePath()
@onready var _agent: NavigationAgent2D = $EnemyNavAgent
@onready var agent_rid: RID = _agent.get_navigation_map()
@onready var _path_timer: Timer = $PathTimer

var _path : PackedVector2Array  = []
var path_direction: Vector2 = Vector2.ZERO

@export var mana : int
@export var maxMana : int

var mouse_in_sprite = false

var blood = load("res://BloodParticles.tscn")

var dying = false

var attacking = false

var original_position = Vector2()
var is_aggroed = false

#_agent.set_debug_enabled(true) # if you want to draw the path

# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = global_position
	_path_timer.connect("timeout", Callable(self, "_update_pathfinding"))
	
	#DETTA BÖR GÖRAS I WOLF, INTE ENEMY
	timer.wait_time = attackRate
	timer.start()
	health_bar._on_health_updated(curHp, maxHp)
	health_bar._on_mana_updated(mana, maxMana)
	#SÄTT ALLA VÄRDEN, ATTACK, DEFENSE, OSV
	
func _update_pathfinding() -> void:
	if !is_instance_valid(target) or not is_aggroed:
		return
	_agent.set_target_position(target.global_position)


func _process(_delta):
	if !hasSkills:
		return
	if dying or attacking:
		return
	handle_skills()


#KAN OVERRIDAS I BARN-NODEN. KÖR .handle_skills() FÖR ATT KÖRA FÖRÄLDERNS HANDLE SKILLS OM OVERRIDE
func handle_skills():
	if canHeal and curHp <= 10:
		canHeal = false
		await get_tree().create_timer(0.25).timeout
		var skill = load("res://SingleTargetHeal.tscn")
		var skill_instance = skill.instantiate()
		skill_instance.skill_name = "10005"
		add_child(skill_instance)
		await get_tree().create_timer(3).timeout
		canHeal = true
	if !is_instance_valid(target):
		return
	if canThrowFireBall and is_aggroed and target.position.distance_to(position) < ImportData.skill_data["10008"].SkillRange:
		canThrowFireBall = false
		get_node("TurnAxis").rotation = get_angle_to(target.get_global_position())
		var skill = load("res://RangedSingleTargetTargetedSkill.tscn")
		var skill_instance = skill.instantiate()
		skill_instance.get_node("PointLight2D").color = Color("f0b86a")
		skill_instance.skill_name = "10008"
		skill_instance.caster = self
		skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
		skill_instance.rotation = get_angle_to(target.get_global_position())
		get_parent().add_child(skill_instance)
		await get_tree().create_timer(6).timeout
		canThrowFireBall = true


func _physics_process(_delta):
	if user_name == 'Dragon':
		var test = "test"
	if not is_aggroed:
		return
	
	var move_away_vel = Vector2.ZERO
	for entity in SpacingArea.get_overlapping_areas(): # Use get_overlapping_areas for Area2D detection
		if entity.is_in_group("Spacing"):
			var direction_to_entity = global_position.direction_to(entity.global_position)
			move_away_vel = -direction_to_entity.normalized() * 0.5
		
	# If the target is invalid, the agent is dying, or attacking, return
	if !is_instance_valid(target) or dying or attacking:
		return
		
	var dist = global_position.distance_to(target.global_position)
	if dist < 85:
		get_node("LightOccluder2D").hide()
	else:
		get_node("LightOccluder2D").show()

	# Set the facing direction based on the target's position
	facingDir = Vector2(sign(target.global_position.x - global_position.x), 0)

	# Update the path to the target
	if not _agent.is_target_reached() and dist > attackDist:
		var next_pos = _agent.get_next_path_position()
		vel = (next_pos - global_position).normalized()
		_agent.set_velocity(vel)
	else:
		vel = Vector2.ZERO  # Stop the agent if the target is reached
	
	set_velocity((vel + move_away_vel).normalized() * moveSpeed)
	
	if vel != Vector2.ZERO:
		move_and_slide()
		
	manage_animations()

func manage_animations ():
	if vel == Vector2.ZERO:
		if facingDir.x > 0:
			play_animation("idle_right")
		else:
			play_animation("idle_left")
	else:
		if vel.x > 0:
			play_animation("run_right")
		else:
			play_animation("run_left")


func play_animation (anim_name):
	if anim.current_animation != anim_name:
		anim.play(anim_name)

func _on_Timer_timeout():
	if !is_instance_valid(target):
		return
	if position.distance_to(target.position) <= attackDist:
		start_attack_animation()

func start_attack_animation():
	if attacking or position.distance_to(target.position) >= attackDist:
		return
	else:
		attacking = true
		if facingDir.x > 0:
			play_animation("hit_right")
		else:
			play_animation("hit_left")

func attack_from_animation():
	target.take_damage(attack, critChance, critFactor, true)

func attack_animation_done():
	attacking = false

func OnHeal(heal_amount):
	if curHp + heal_amount >= maxHp:
		curHp = maxHp
	else:
		curHp += heal_amount
	var text = floating_text.instantiate()
	text.amount = heal_amount
	text.type = "Heal"
	text.set_position(position)
	get_tree().get_root().add_child(text)
	mana -= 2
	health_bar._on_health_updated(curHp, maxHp)
	health_bar._on_mana_updated(mana, maxMana)
	if target.targeted == self:
		ui_health_bar.load_ui(self)

func take_damage(attack, critChance, critFactor, in_range):
	if is_instance_valid(target):
		is_aggroed = true
	var dmgToTake = attack*(float(50)/(50+defense))
	var type = ""
	var text = floating_text.instantiate()
	randomize()
	if !in_range:
		type = "Miss"
		dmgToTake = 0
	elif randf() <= blockChance:
		type = "Block"
		dmgToTake *= 0.5
		var second_text = floating_text.instantiate()
		second_text.amount = -1
		second_text.type = "Block"
		second_text.set_position(position)
		get_tree().get_root().add_child(second_text)
	elif randf() <= dodgeChance:
		type = "Dodge"
		dmgToTake = 0
	elif randf() <= critChance:
		dmgToTake *= critFactor
		type = "Critical"
	else:
		type = "Damage"
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	dmgToTake *= rng.randf_range(0.5, 1.5)
	if int(dmgToTake) <= 0:
		dmgToTake = 1
	if type == "Dodge":
		dmgToTake = 0
	if not in_range:
		dmgToTake = 0
		type = "Miss"
	text.amount = int(dmgToTake)
	text.type = type
	curHp -= int(dmgToTake)
	text.set_position(position)
	get_tree().get_root().add_child(text)
	health_bar._on_health_updated(curHp, maxHp)
	if target.targeted == self:
		ui_health_bar.load_ui(self)
	if curHp <= 0:
		die()


func die():
	if mouse_in_sprite:
		get_node("/root/MainScene/CanvasLayer/MouseCursorAttack").reset_cursor()
	var blood_instance = blood.instantiate()
	blood_instance.position = position
	blood_instance.rotation = position.angle_to_point(target.position)
	get_tree().current_scene.add_child(blood_instance)
	target.give_xp(xpToGive)
	target.update_quests("Kill", user_name, 1)
	if target.targeted == self:
		ui_health_bar.hide()
		target.auto_attacking = false
		target.targeted = null
	var box = loot_box.instantiate()
	box.set_loot(user_name)
	box.set_position(position)
	get_tree().current_scene.add_child(box)
	dying = true
	
	queue_free()


func _on_area_2d_mouse_entered():
	get_node("/root/MainScene/CanvasLayer/MouseCursorAttack").set_as_cursor()
	mouse_in_sprite = true


func _on_area_2d_mouse_exited():
	get_node("/root/MainScene/CanvasLayer/MouseCursorAttack").reset_cursor()
	mouse_in_sprite = false


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				get_node("/root/MainScene/CanvasLayer/MouseCursorAttack").click()
				if target.targeted != self:
					target.target_enemy(self)
				if (target.targeted != null):
					target.auto_attacking = true
			MOUSE_BUTTON_LEFT:
				if !target.hasSkillCursor:
					target.target_enemy(self)


func _on_aggro_area_body_entered(body):
	if body == target:  # Check if the entered body is the target
		is_aggroed = true
		_update_pathfinding()


func _on_de_aggro_area_body_exited(body):
	if body == target:  # Check if the exited body is the target
		is_aggroed = false
		_agent.set_target_position(global_position) # Simply stops moving
		#_agent.set_target_position(original_position)  # Set target back to original position


func set_attack_rate(seconds):
	attackRate = seconds
	timer.wait_time = attackRate
