extends KinematicBody2D

var floating_text = preload("res://FloatingText.tscn")

var user_name = "Skeleton"
var curHp : int = 20
var maxHp : int = 20
var moveSpeed : int = 50
var facingDir = Vector2()
var vel = Vector2()
var xpToGive : int = 30
var damage : int = 1
var attackRate : float = 1.0
var changeDir = false
var attackDist : int = 40
var chaseDist : int = 400
onready var timer = $Timer
onready var target = get_node("/root/MainScene/Player")
onready var anim = $AnimatedSprite
onready var health_bar = $HealthBar
var step : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = attackRate
	timer.start()
	health_bar._on_health_updated(curHp, maxHp)
	
func _physics_process (delta):
	vel = Vector2()
	
	if step % 30 == 0:
		changeDir = true
	else:
		changeDir = false
	
	var dist1 = position - target.position

	var dist = position.distance_to(target.position)
	# Move only if target is too far away to attack and close enough to chase
	if dist > attackDist and dist < chaseDist:
		if changeDir:
			if abs(dist1.x) > abs(dist1.y):
				if dist1.x > 0:
					facingDir = Vector2(-1, 0)
				else:
					facingDir = Vector2(1, 0)
			else:
				if dist1.y > 0:
					facingDir = Vector2(0, -1)
				else:
					facingDir = Vector2(0, 1)
					
		walk(facingDir)
			
		#var vel = (target.position - position).normalized()
		#move_and_slide(vel * moveSpeed)

		move_and_slide(vel * moveSpeed, Vector2.ZERO)
		manage_animations()
		step += 1


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
	if position.distance_to(target.position) <= attackDist:
		target.take_damage(damage)

func take_damage (dmgToTake):
	var type = ""
	randomize()
	if randf() > 0.5:
		dmgToTake = 2
		type = "Critical"
	else:
		type = "Damage"
	curHp -= dmgToTake
	var text = floating_text.instance()
	text.amount = dmgToTake
	text.type = type
	add_child(text)
	health_bar._on_health_updated(curHp, maxHp)
	if curHp <= 0:
		die()
		
func heal(heal_amount):
	var text = floating_text.instance()
	text.amount = heal_amount
	text.type = "Heal"
	add_child(text)
	if curHp < maxHp:
		curHp += heal_amount
	health_bar._on_health_updated(curHp, maxHp)
		
func die ():
	target.give_xp(xpToGive)
	if target.targeted == self:
		target.targeted = null
	queue_free()

func _on_Enemy_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		target.target_enemy(self)
