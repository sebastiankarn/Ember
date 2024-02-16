extends CharacterBody2D

#@onready var nav : Navigation2D = $Navigation2D
@onready var loot_box = preload("res://Chest.tscn")

var floating_text = preload("res://FloatingText.tscn")
#@onready var navAgent = $EnemyNavAgent
var user_name = "Wolf"
var curHp : int = 30
var maxHp : int = 30
var moveSpeed : int = 70
var facingDir = Vector2()
var vel = Vector2()
var xpToGive : int = 20
var attack : int = 7
var critChance : float = 0.1
var critFactor : float = 1.5
var blockChance : float = 0.05
var dodgeChance : float = 0.1
var defense: int = 5
var attackRate : float = 1.0
var changeDir = false
var attackDist : int = 60
var chaseDist : int = 300
@onready var timer = $Timer
@onready var target = get_node("/root/MainScene/Player")
@onready var anim = $AnimationPlayer
@onready var health_bar = $HealthBar
@onready var ui_health_bar = get_node("/root/MainScene/CanvasLayer/EnemyUI")
var step : int = 0
var i : int =  0
var _update_every : int = 500
var canHeal = true
var canThrowFireBall = false

@export var path_to_target := NodePath()
@onready var _agent: NavigationAgent2D = $EnemyNavAgent
@onready var _path_timer: Timer = $PathTimer

var _path : Array = []
var path_direction: Vector2 = Vector2.ZERO
var direction_to_target: Vector2 = Vector2.ZERO

var mana = 100
var maxMana = 100

var mouse_in_sprite = false

var blood = load("res://BloodParticles.tscn")

var dying = false

var attacking = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_update_pathfinding()
	_path_timer.connect("timeout", Callable(self, "_update_pathfinding"))
	timer.wait_time = attackRate
	timer.start()
	health_bar._on_health_updated(curHp, maxHp)
	health_bar._on_mana_updated(mana, maxMana)

func _update_pathfinding() -> void:
	if !is_instance_valid(target):
		return
	_agent.set_target_position(target.position)
	
func _process(_delta):
	if dying or attacking:
		return
	
func navigate(path : Array) -> void:
	_path = path
	if path.size():
		_agent.set_target_position(path[0])
	
func get_enemy_rid() -> RID:
	return _agent.get_navigation_map()
	
func _physics_process(_delta):
	# If too far away to chase, return
	if !is_instance_valid(target) or dying or attacking:
		return
	var dist = position.distance_to(target.position)
	if dist < 85:
		get_node("LightOccluder2D").hide()
	else:
		get_node("LightOccluder2D").show()
	if dist > chaseDist:
		return
		
	direction_to_target = position.direction_to(target.position)
	if direction_to_target.x > 0:
		facingDir = Vector2(1, 0)
	else:
		facingDir = Vector2(-1, 0)
	
	# The path is only updated every now and then
	if i % _update_every == 0:	
		var path = NavigationServer2D.map_get_path(get_enemy_rid(), position, target.position, false)
		path.remove_at(0)
		navigate(path)
		
	vel = Vector2()
	
	if _path.size() > 0:
		var current_pos = position
		var next_pos = _agent.get_next_path_position()
		path_direction = current_pos.direction_to(next_pos)
		vel = path_direction * moveSpeed
		_agent.set_velocity(vel)
		if current_pos.distance_to(next_pos) < 5:
#			_path.remove(0)
			if _path.size():
				_agent.set_target_position(_path[0])
		i += 1

	# Stop moving if target is withing attack range
	if dist < attackDist:
		vel = Vector2()

	set_velocity(vel)
	#set_up_direction(Vector2.UP)
	move_and_slide()
	manage_animations()

#func _on_EnemyNavAgent_velocity_computed(safe_velocity: Vector2) -> void:
	#set_velocity(safe_velocity)
	#move_and_slide()
	##var velocity = velocity


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
	get_tree().get_root().add_child(box)
	dying = true
	#await get_tree().create_timer(3).timeout
	
	queue_free()

func _on_Enemy_input_event(viewport, event, shape_idx):
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

func _on_Enemy_mouse_entered():
	get_node("/root/MainScene/CanvasLayer/MouseCursorAttack").set_as_cursor()
	mouse_in_sprite = true


func _on_Enemy_mouse_exited():
	get_node("/root/MainScene/CanvasLayer/MouseCursorAttack").reset_cursor()
	mouse_in_sprite = false
