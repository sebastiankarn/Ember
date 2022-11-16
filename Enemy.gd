extends KinematicBody2D

var curHp : int = 5
var maxHp : int = 5
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
var step : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = attackRate
	timer.start()
	
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
	curHp -= dmgToTake
	if curHp <= 0:
		die()
func die ():
	target.give_xp(xpToGive)
	queue_free()



func _on_Enemy_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		target.target_enemy(self)
