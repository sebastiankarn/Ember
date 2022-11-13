extends KinematicBody2D

var curHp : int = 5
var maxHp : int = 5
var moveSpeed : int = 150
var xpToGive : int = 30
var damage : int = 1
var attackRate : float = 1.0
var attackDist : int = 80
var chaseDist : int = 400
onready var timer = $Timer
onready var target = get_node("/root/MainScene/Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = attackRate
	timer.start()

func _physics_process (delta):
	var dist = position.distance_to(target.position)
	if dist > attackDist and dist < chaseDist:
		var vel = (target.position - position).normalized()
		move_and_slide(vel * moveSpeed)


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
