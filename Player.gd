extends KinematicBody2D

var floating_text = preload("res://FloatingText.tscn")

var curHp : int = 50
var maxHp : int = 50
var user_name = "MangoPowder"

var stat_points = 9
var skill_points = 9

var strength = 30
var constitution = 10
var dexterity = 30
var intelligence = 50
var wisdom = 15

var attackSpeed = 1.0
var autoAttacking = false

var skill_1A = true
var skill_1B = true
var skill_2A = false
var skill_2B = false
var skill_2C = false
var skill_3A = false

var spell = preload("res://Spell.tscn")
var can_fire = true
var rate_of_fire = 0.4
var casting = false

var selected_skill

var moveSpeed : int = 120
var damage : int = 1
var gold : int = 0
var curLevel : int = 9
var curXp : int = 0
var xpToNextLevel : int = 50
var xpToLevelIncreaseRate : float = 1.2
var interactDist : int = 70
var vel = Vector2()
var facingDir = Vector2()
var targeted = null
var walkingKeys = [0,0,0,0]
var attackDist : int = 40
var autoAttack_cd = 1
onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite
onready var ui = get_node("/root/MainScene/CanvasLayer/UI")
onready var health_bar = $HealthBar
onready var targetShader = preload("res://shaders/outline.shader")

func _ready():
	ui.update_level_text(curLevel)
	ui.update_health_bar(curHp, maxHp)
	ui.update_xp_bar(curXp, xpToNextLevel)
	ui.update_gold_text(gold)
	health_bar._on_health_updated(curHp, maxHp)
	
func SkillLoop():
	if Input.is_action_pressed("Shoot") and can_fire == true:
		can_fire = false
		casting = true
		var oldMoveSpeed = moveSpeed
		moveSpeed = 0
		get_node("TurnAxis").rotation = get_angle_to(get_global_mouse_position())
		var spell_instance = spell.instance()
		spell_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
		spell_instance.rotation = get_angle_to(get_global_mouse_position())
		get_parent().add_child(spell_instance)
		print(spell_instance.position)
		print(spell_instance.rotation)
		yield(get_tree().create_timer(rate_of_fire), "timeout")
		can_fire = true
		casting = false
		moveSpeed = oldMoveSpeed


func _physics_process (delta):
	
	vel = Vector2()
	var vert_move = false
	var hori_move = false
	var up : int = Input.is_action_pressed("move_up")
	var down : int = Input.is_action_pressed("move_down")
	var vert_sum = up + down
	var right : int = Input.is_action_pressed("move_right")
	var left : int = Input.is_action_pressed("move_left")
	var hori_sum = right + left
	
	var old_keys = walkingKeys
	walkingKeys = [up,down,right,left]
	
	if vert_sum == 1 and hori_sum == 1:
		if walkingKeys == old_keys:
			# Just keep moving the same direction
			walk(facingDir)
			vert_sum = 0
			hori_sum = 0

		else:
			if facingDir.y != 0:
				vert_sum = 0
			else:
				hori_sum = 0

	if vert_sum == 1:
		if up:
			facingDir = Vector2(0, -1)
		else:
			facingDir = Vector2(0, 1)
			
		walk(facingDir)
			
	
	if hori_sum == 1:
		if right:
			facingDir = Vector2(1, 0)
		else:
			facingDir = Vector2(-1, 0)
			
		walk(facingDir)
			
	move_and_slide(vel * moveSpeed, Vector2.ZERO)
	manage_animations()

func walk(dir):
	vel.x += dir[0]
	vel.y += dir[1]
	

func manage_animations ():
	if casting == true:
		if facingDir.x == 1:
			play_animation("IdleRight")
		elif facingDir.x == -1:
			play_animation("IdleLeft")
		elif facingDir.y == -1:
			play_animation("IdleUp")
		elif facingDir.y == 1:
			play_animation("IdleDown")
	else:
		if vel.x > 0:
			play_animation("MoveRight")
		elif vel.x < 0:
			play_animation("MoveLeft")
		elif vel.y < 0:
			play_animation("MoveUp")
		elif vel.y > 0:
			play_animation("MoveDown")
		elif facingDir.x == 1:
			play_animation("IdleRight")
		elif facingDir.x == -1:
			play_animation("IdleLeft")
		elif facingDir.y == -1:
			play_animation("IdleUp")
		elif facingDir.y == 1:
			play_animation("IdleDown")
		
func play_animation (anim_name):
  
	if anim.animation != anim_name:
		anim.play(anim_name)

func give_gold (amount):
	gold += amount
	ui.update_gold_text(gold)
	
func give_xp (amount):
	curXp += amount
	if curXp >= xpToNextLevel:
		level_up()
	ui.update_xp_bar(curXp, xpToNextLevel)
	
func level_up ():
	var overflowXp = curXp - xpToNextLevel
	xpToNextLevel *= xpToLevelIncreaseRate
	curXp = overflowXp
	curLevel += 1
	ui.update_level_text(curLevel)
	ui.update_xp_bar(curXp, xpToNextLevel)
	stat_points += 5
	skill_points += 4
	
func take_damage (dmgToTake):
	curHp -= dmgToTake
	var text = floating_text.instance()
	text.amount = dmgToTake
	text.type = "Damage"
	add_child(text)
	if curHp <= 0:
		die()
	ui.update_health_bar(curHp, maxHp)
	health_bar._on_health_updated(curHp, maxHp)
		
func die ():
	get_tree().reload_current_scene()
	
func _process (delta):
	if Input.is_action_just_pressed("interact"):
		try_interact()
	if Input.is_action_just_pressed("auto_attack"):
		auto_attack()
	SkillLoop()

func try_interact ():
	rayCast.cast_to = facingDir * interactDist
	if rayCast.is_colliding():
		if rayCast.get_collider() is KinematicBody2D:
			rayCast.get_collider().take_damage(damage)
		elif rayCast.get_collider().has_method("on_interact"):
			rayCast.get_collider().on_interact(self)
			
func target_enemy (enemy):
	if targeted == enemy:
		enemy.get_node("AnimatedSprite").material.shader = null
		targeted = null
	else:
		targeted = enemy
		enemy.get_node("AnimatedSprite").material.shader = targetShader
		enemy.get_node("AnimatedSprite").material.set_shader_param("outline_color", Color.red)
		auto_attack()

func auto_attack ():
	if autoAttacking == false:
		autoAttacking = true
		yield(get_tree().create_timer(autoAttack_cd), "timeout")
		if targeted == null or position.distance_to(targeted.position) > attackDist:
			autoAttacking = false
		else:
			if position.distance_to(targeted.position) <= attackDist and targeted != null:
				targeted.take_damage(damage)
				autoAttacking = false
				auto_attack()

func next_auto() -> void:
	if targeted != null:
		if position.distance_to(targeted.position) <= attackDist and targeted != null:
			auto_attack()
