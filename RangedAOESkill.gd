extends Area2D

var skill_name
var damage = 7
var animation = "Fire_Ring"
var damage_delay_time = 0.1
var remove_delay_time = 0.3

func _ready():
	AOEAttack()

func AOEAttack():
	get_node("AnimationPlayer").play(animation)
	yield(get_tree().create_timer(damage_delay_time), "timeout")
	var targets = get_overlapping_bodies()
	for target in targets:
		target.take_damage(damage)
	yield(get_tree().create_timer(remove_delay_time), "timeout")
	self.queue_free()
