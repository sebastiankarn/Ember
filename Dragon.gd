extends KinematicBody2D

onready var nav : Navigation2D = $Navigation2D
onready var loot_box = preload("res://Chest.tscn")

var floating_text = preload("res://FloatingText.tscn")
onready var navAgent = $EnemyNavAgent
var user_name = "Dragon"
var curHp : int = 75
var maxHp : int = 75
var moveSpeed : int = 50
var facingDir = Vector2()
var vel = Vector2()
var xpToGive : int = 80
var attack : int = 80
var critChance : float = 0.1
var critFactor : float = 1.5
var blockChance : float = 0.05
var dodgeChance : float = 0.1
var defense: int = 50
var attackRate : float = 1.0
var changeDir = false
var attackDist : int = 60
var chaseDist : int = 300
onready var timer = $Timer
onready var target = get_node("/root/MainScene/Player")
onready var anim = $AnimatedSprite
onready var health_bar = $HealthBar
onready var ui_health_bar = get_node("/root/MainScene/CanvasLayer/EnemyUI")
var step : int = 0
var i : int =  0
var _update_every : int = 500
var canHeal = true
var canThrowFireBall = true

export var path_to_target := NodePath()
onready var _agent: NavigationAgent2D = $EnemyNavAgent
onready var _path_timer: Timer = $PathTimer

var _path : Array = []
var direction: Vector2 = Vector2.ZERO

var mana = 100
var maxMana = 100

var blood = load("res://Blood.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	_update_pathfinding()
	_path_timer.connect("timeout", self, "_update_pathfinding")
	timer.wait_time = attackRate
	timer.start()
	health_bar._on_health_updated(curHp, maxHp)
	health_bar._on_mana_updated(mana, maxMana)

func _update_pathfinding() -> void:
	if !is_instance_valid(target):
		return
	_agent.set_target_location(target.position)
	
func _process (delta):
	if curHp <= 10 and canHeal:
		canHeal = false
		yield(get_tree().create_timer(0.25), "timeout")
		var skill = load("res://SingleTargetHeal.tscn")
		var skill_instance = skill.instance()
		skill_instance.skill_name = "10005"
		add_child(skill_instance)
		yield(get_tree().create_timer(3), "timeout")
		canHeal = true
	if !is_instance_valid(target):
		return
	if canThrowFireBall and target.position.distance_to(position) < ImportData.skill_data["10008"].SkillRange:
		canThrowFireBall = false
		get_node("TurnAxis").rotation = get_angle_to(target.get_global_position())
		var skill = load("res://RangedSingleTargetTargetedSkill.tscn")
		var skill_instance = skill.instance()
		skill_instance.get_node("Light2D").color = Color("f0b86a")
		skill_instance.skill_name = "10008"
		skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
		skill_instance.rotation = get_angle_to(target.get_global_position())
		get_parent().add_child(skill_instance)
		yield(get_tree().create_timer(6), "timeout")
		canThrowFireBall = true
	
func navigate(path : Array) -> void:
	_path = path
	if path.size():
		navAgent.set_target_location(path[0])
	
func get_enemy_rid() -> RID:
	return navAgent.get_navigation_map()
	
func _physics_process (delta):
	
	# If too far away to chase, return
	if !is_instance_valid(target):
		return
	var dist = position.distance_to(target.position)
	if dist < 85:
		get_node("LightOccluder2D").hide()
	else:
		get_node("LightOccluder2D").show()
	if dist > chaseDist:
		return
	
	# The path is only updated every now and then
	if i % _update_every == 0:	
		var path = Navigation2DServer.map_get_path(get_enemy_rid(), position, target.position, false)
		path.remove(0)
		navigate(path)
		
	vel = Vector2()
	
	if _path.size() > 0:
		var current_pos = position
		var next_pos = navAgent.get_next_location()
		direction = current_pos.direction_to(next_pos)
		navAgent.set_velocity(direction * moveSpeed)
		if current_pos.distance_to(next_pos) < 5:
			_path.remove(0)
			if _path.size():
				navAgent.set_target_location(_path[0])
		i += 1
		
		if step % 30 == 0:
			changeDir = true
		else:
			changeDir = false

		# Move only if target is too far away to attack and close enough to chase
		if dist > attackDist: # and dist < chaseDist:
			if changeDir:
				if abs(direction.x) > abs(direction.y):
					if direction.x > 0:
						facingDir = Vector2(1, 0)
					else:
						facingDir = Vector2(-1, 0)
				else:
					if direction.y > 0:
						facingDir = Vector2(0, 1)
					else:
						facingDir = Vector2(0, -1)
			walk(facingDir)
			step += 1

		else:
			# Make sure to face target while fighting
			if dist <= attackDist:
				if abs(direction.x) > abs(direction.y):
					if direction.x > 0:
						facingDir = Vector2(1, 0)
					else:
						facingDir = Vector2(-1, 0)
				else:
					if direction.y > 0:
						facingDir = Vector2(0, 1)
					else:
						facingDir = Vector2(0, -1)
		move_and_slide(vel * moveSpeed, Vector2.ZERO)
		manage_animations()

func _on_EnemyNavAgent_velocity_computed(safe_velocity: Vector2) -> void:
	var velocity = move_and_slide(safe_velocity)

func walk(dir):
	vel.x += dir[0]
	vel.y += dir[1]
	

func manage_animations ():
  
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

func _on_Timer_timeout():
	if !is_instance_valid(target):
		return
	if position.distance_to(target.position) <= attackDist:
		target.take_damage(attack, critChance, critFactor)

func OnHeal(heal_amount):
	if curHp + heal_amount >= maxHp:
		curHp = maxHp
	else:
		curHp += heal_amount
	var text = floating_text.instance()
	text.amount = heal_amount
	text.type = "Heal"
	text.set_position(position)
	get_tree().get_root().add_child(text)
	mana -= 2
	health_bar._on_health_updated(curHp, maxHp)
	health_bar._on_mana_updated(mana, maxMana)
	if target.targeted == self:
		ui_health_bar.load_ui(self)

func take_damage (attack, critChance, critFactor):
	var dmgToTake = attack*(float(50)/(50+defense))
	if dmgToTake < 0:
		dmgToTake = 0
	var type = ""
	var text = floating_text.instance()
	randomize()
	if randf() <= blockChance:
		type = "Block"
		dmgToTake *= 0.5
		var second_text = floating_text.instance()
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
	if dmgToTake <= 0:
		dmgToTake = 1
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	dmgToTake *= rng.randf_range(0.5, 1.5)
	text.amount = int(dmgToTake)
	text.type = type
	curHp -= (dmgToTake)
	text.set_position(position)
	get_tree().get_root().add_child(text)
	health_bar._on_health_updated(curHp, maxHp)
	if target.targeted == self:
		ui_health_bar.load_ui(self)
	if curHp <= 0:
		die()
		
		
func die():
	var blood_instance = blood.instance()
	blood_instance.position = position
	blood_instance.rotation = position.angle_to_point(target.position)
	get_tree().current_scene.add_child(blood_instance)
	target.give_xp(xpToGive)
	if target.targeted == self:
		ui_health_bar.hide()
		target.targeted = null
		target.targeted = null
	var box = loot_box.instance()
	box.set_loot(user_name)
	box.set_position(position)
	get_tree().get_root().add_child(box)
	queue_free()

func _on_Enemy_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		target.target_enemy(self)
