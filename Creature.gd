extends CharacterBody2D

@export var user_name = "Skeleton"
@export var curHp : int = 20
@export var maxHp : int = 20
@export var vel: Vector2 = Vector2.ZERO
@export var mana = 100
@export var maxMana = 100
@export var defense = 100
@export var blockChance = 100
@export var maxMana = 100
var facingDir = Vector2(0, 1)
@onready var health_bar = $HealthBar
var blood = load("res://BloodParticles.tscn")
var floating_text = preload("res://FloatingText.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar._on_health_updated(curHp, maxHp)
	health_bar._on_mana_updated(mana, maxMana)

func _physics_process(_delta):
	move_and_slide()
	manage_animations()

func manage_animations():
	if vel == Vector2.ZERO:
		if facingDir.x == 1:
			play_animation("IdleRight")
		elif facingDir.x == -1:
			play_animation("IdleLeft")
		elif facingDir.y == -1:
			play_animation("IdleUp")
		elif facingDir.y == 1:
			play_animation("IdleDown")
	else:
		if abs(vel.x) > abs(vel.y):
			if vel.x > 0:
				play_animation("MoveRight")
			else:
				play_animation("MoveLeft")
		else:
			if vel.y > 0:
				play_animation("MoveDown")
			else:
				play_animation("MoveUp")


func play_animation (anim_name):
	return

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
		
		
func die ():
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

