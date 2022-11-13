extends KinematicBody2D

var curHp : int = 10
var maxHp : int = 10
var moveSpeed : int = 250
var damage : int = 1
var gold : int = 0
var curLevel : int = 0
var curXp : int = 0
var xpToNextLevel : int = 50
var xpToLevelIncreaseRate : float = 1.2
var interactDist : int = 70
var vel = Vector2()
var facingDir = Vector2()
var walkingKeys = [0,0,0,0]
onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite

func _ready():
	pass
	
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
