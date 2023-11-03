extends Area2D

var skill_name
var health
var radius
var remove_delay_time
var expansion_time
var damaged_targets = []
var duration

func _ready():
	health = ImportData.skill_data[skill_name].SkillHeal
	var scaled_health = ImportData.skill_data[skill_name].Scale * PlayerData.player_stats[ImportData.skill_data[skill_name].ScaleAttribute]
	health += scaled_health
	radius = ImportData.skill_data[skill_name].SkillRadius
	duration = ImportData.skill_data[skill_name].SkillDuration
	get_parent().OnHeal(15)
	PlayerData.player_stats["Defense"] += 5
	PlayerData.LoadStats()
	_draw()
	yield(get_tree().create_timer(duration), "timeout")
	PlayerData.player_stats["Defense"] -= 5
	PlayerData.LoadStats()
	queue_free()

func _draw():
	var center = Vector2(0, 0)
	var color = Color("e4a717")
	self.draw_circle(center, radius, color)


