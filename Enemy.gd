extends CharacterBody2D

var draw_path : bool = false  # A flag to toggle path drawing


@onready var loot_box = preload("res://Chest.tscn")
var floating_text = preload("res://FloatingText.tscn")
@onready var nav_agent = $EnemyNavAgent
var user_name = "Skeleton3D"
var curHp : int = 20
var maxHp : int = 20
var vel: Vector2 = Vector2.ZERO
var moveSpeed : int = 50
var xpToGive : int = 30
var attack : int = 5
var critChance : float = 0.1
var critFactor : float = 1.5
var blockChance : float = 0.05
var dodgeChance : float = 0.1
var defense: int = 60
var attackRate : float = 2.0
var attackDist : int = 40
var chaseDist : int = 300
var ligthDist : int = 85
@onready var timer = $Timer
@onready var target = get_node("/root/MainScene/Player")
@onready var anim = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var ui_health_bar = get_node("/root/MainScene/CanvasLayer/EnemyUI")
var step : int = 0
var i : int =  0
var _update_every : int = 1
var canHeal = true

@onready var _path_timer: Timer = $PathTimer

var _path : Array = []
var direction: Vector2 = Vector2.ZERO
var next_pos: Vector2 = Vector2.ZERO

var mana = 100
var maxMana = 100

var blood = load("res://Blood.tscn")

var mouse_in_sprite = false

#var target_node = null
var home_pos = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
#	_path_timer.connect("timeout", self, "_update_pathfinding")
	home_pos = self.global_position
	timer.wait_time = attackRate
	timer.start()
	health_bar._on_health_updated(curHp, maxHp)
	health_bar._on_mana_updated(mana, maxMana)

func recalc_path():
	if target:
		nav_agent.target_position = target.global_position
	else:
		nav_agent.target_position = home_pos

func _on_path_timer_timeout():
	recalc_path()

func _on_enemy_nav_agent_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()

#func _draw():
#	if draw_path and _path.size() > 1:
#		for i in range(_path.size() - 1):
#			draw_line(_path[i] - position, _path[i+1] - position, Color(1, 0, 0, 1), 2)
#
#func _update_pathfinding() -> void:
#	if draw_path:
#		update()
#	if !is_instance_valid(target):
#		return
#	navAgent.set_target_position(target.position)

func _physics_process (delta):
	
	var dist = position.distance_to(target.position)
	
	# If too far away to chase, return
	if dist > chaseDist:
		return
	
	if dist < ligthDist:
		get_node("LightOccluder2D").hide()
	else:
		get_node("LightOccluder2D").show()
	
	if !is_instance_valid(target):
		return

	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	var vel = axis * moveSpeed

#	_update_pathfinding()
#	_path = NavigationServer2D.map_get_path(navAgent.get_navigation_map(), position, target.position, false)
#	_path.remove(0)
#
#	if _path.size() > 0:
#		next_pos = navAgent.get_next_path_position()
#		direction = position.direction_to(next_pos)
#		vel = direction * moveSpeed

	if dist < attackDist:
		vel = Vector2.ZERO
	nav_agent.set_velocity(vel)
		
#		set_velocity(vel)
#		set_up_direction(Vector2.ZERO)
	move_and_slide()
	manage_animations()

func manage_animations():
	if vel == Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				play_animation("IdleRight")
			else:
				play_animation("IdleLeft")
		else:
			if direction.y > 0:
				play_animation("IdleDown")
			else:
				play_animation("IdleUp")
	else:
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				play_animation("MoveRight")
			else:
				play_animation("MoveLeft")
		else:
			if direction.y > 0:
				play_animation("MoveDown")
			else:
				play_animation("MoveUp")


func play_animation (anim_name):
  
	if anim.animation != anim_name:
		anim.play(anim_name)

func _on_Timer_timeout():
	if !is_instance_valid(target):
		return
	if position.distance_to(target.position) <= attackDist:
		target.take_damage(attack, critChance, critFactor, true)

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

func take_damage (attack, critChance, critFactor, in_range):
	var dmgToTake = attack*(float(50)/(50+defense))
	var type = ""
	var text = floating_text.instantiate()
	randomize()
	if randf() <= blockChance:
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
		
		
func die ():
	if mouse_in_sprite:
		get_node("/root/MainScene/CanvasLayer/MouseCursorAttack").reset_cursor()
	var blood_instance = blood.instance()
	blood_instance.position = position
	blood_instance.rotation = position.angle_to_point(target.position)
	get_tree().current_scene.add_child(blood_instance)
	target.give_xp(xpToGive)
	if target.targeted == self:
		ui_health_bar.hide()
		target.auto_attacking = false
		target.targeted = null
	var box = loot_box.instantiate()
	box.set_loot(user_name)
	box.set_position(position)
	get_tree().get_root().add_child(box)
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
