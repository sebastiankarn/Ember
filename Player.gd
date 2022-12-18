extends KinematicBody2D

var floating_text = preload("res://FloatingText.tscn")

var user_name = "MangoPowder"

var stat_points = 5
var skill_points = 4

var health = 100
var mana = 100
var autoAttacking = false

var skill_1A = true
var skill_1B = true
var skill_2A = false
var skill_2B = false
var skill_2C = false
var skill_3A = false

var can_fire = true
var rate_of_fire = 1
var casting = false

var selected_skill

var gold : int = 0
var curXp : int = 0
var xpToNextLevel : int = 50
var xpToLevelIncreaseRate : float = 1.2
var interactDist : int = 70
var vel = Vector2()
var facingDir = Vector2()
var targeted = null
var walkingKeys = [0,0,0,0]
var attackDist : int = 40

var tabbed_enemies = []

onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite
onready var anim_arms = $AnimationArms
onready var ui = get_node("/root/MainScene/CanvasLayer/UI")
onready var health_bar = $HealthBar
onready var targetShader = preload("res://shaders/outline.shader")
onready var on_hand_sprite = $OnHandSprite
onready var character_sheet = get_node("/root/MainScene/CanvasLayer/CharacterSheet")

func _ready():
	PlayerData.LoadStats()
	mana = PlayerData.player_stats["MaxMana"]
	health = PlayerData.player_stats["MaxHealth"]
	print(health)
	ui.update_level_text(PlayerData.player_stats["Level"])
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	ui.update_mana_bar(mana, PlayerData.player_stats["MaxMana"])
	ui.update_xp_bar(curXp, xpToNextLevel)
	ui.update_gold_text(gold)
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_mana_updated(mana, PlayerData.player_stats["MaxMana"])

func update_healthbars():
	ui.update_level_text(PlayerData.player_stats["Level"])
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	ui.update_mana_bar(mana, PlayerData.player_stats["MaxMana"])
	ui.update_xp_bar(curXp, xpToNextLevel)
	ui.update_gold_text(gold)
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_mana_updated(mana, PlayerData.player_stats["MaxMana"])
	

func SkillLoop():
	if can_fire == true:
		can_fire = false
		casting = true
		var fire_direction = (get_angle_to(get_global_mouse_position())/3.14)*180
		get_node("TurnAxis").rotation = get_angle_to(get_global_mouse_position())
		match ImportData.skill_data[selected_skill].SkillType:
			"RangedSingleTargetSkill":
				var skill = load("res://RangedSingleTargetSkill.tscn")
				var skill_instance = skill.instance()
				skill_instance.skill_name = selected_skill
				skill_instance.rotation = get_angle_to(get_global_mouse_position())
				skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
				#Location to add
				get_parent().add_child(skill_instance)
				
			"RangedAOESkill":
				var skill = load("res://RangedAOESkill.tscn")
				var skill_instance = skill.instance()
				skill_instance.skill_name = selected_skill
				skill_instance.position = get_global_mouse_position()
				#Location to add
				get_parent().add_child(skill_instance)
				
			"ExpandingAOESkill":
				var skill = load("res://ExpandingAOESkill.tscn")
				var skill_instance = skill.instance()
				skill_instance.skill_name = selected_skill
				skill_instance.position = get_global_position()
				#add child to map scene
				get_parent().add_child(skill_instance)
				mana += 10
				if mana > PlayerData.player_stats["MaxMana"]:
					mana = PlayerData.player_stats["MaxMana"]
				
			"SingleTargetHeal":
				var skill = load("res://SingleTargetHeal.tscn")
				var skill_instance = skill.instance()
				skill_instance.skill_name = selected_skill
				#Location to add
				add_child(skill_instance)
			
			"RangedSingleTargetTargetedSkill":
				if targeted != null and targeted.get_global_position().distance_to(get_global_position()) < ImportData.skill_data[selected_skill].SkillRange:
					get_node("TurnAxis").rotation = get_angle_to(targeted.get_global_position())
					var skill = load("res://RangedSingleTargetTargetedSkill.tscn")
					var skill_instance = skill.instance()
					skill_instance.skill_name = selected_skill
					skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
					print(ImportData.skill_data[selected_skill].SkillRange)
					print(skill_instance.skill_range)
					print(get_global_position())
					print(targeted.get_global_position())
					skill_instance.rotation = get_angle_to(targeted.get_global_position())
					#Location to add
					get_parent().add_child(skill_instance)
		mana -= 2
		ui.update_mana_bar(mana, PlayerData.player_stats["MaxMana"])
		health_bar._on_mana_updated(mana, PlayerData.player_stats["MaxMana"])
		yield(get_tree().create_timer(rate_of_fire), "timeout")
		can_fire = true
		casting = false

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
	
	# If there is both vertical and horizontal movement, 
	# we have to figure out which axis we move alon
	# since there can only be either vertical or horizontal movement
	if vert_sum == 1 and hori_sum == 1:
		
		# If no change in movement input, keep moving in the same direction
		if walkingKeys == old_keys:
			walk(facingDir)
			vert_sum = 0
			hori_sum = 0
		
		# If there is change in movement input from last time step, change axis
		else:
			if facingDir.y != 0:
				vert_sum = 0
			else:
				hori_sum = 0

	# If there is only movement vertically
	if vert_sum == 1:
		if up:
			facingDir = Vector2(0, -1)
		else:
			facingDir = Vector2(0, 1)
			
		walk(facingDir)
			
	# If there is only movement horizontally
	if hori_sum == 1:
		if right:
			facingDir = Vector2(1, 0)
		else:
			facingDir = Vector2(-1, 0)
			
		walk(facingDir)
			
	move_and_slide(vel * PlayerData.player_stats["MovementSpeed"], Vector2.ZERO)
	manage_animations()

# Function to walk in the provided direction
func walk(dir):
	vel.x += dir[0]
	vel.y += dir[1]
	
func manage_animations ():
#	if casting == true:

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
		anim_arms.play(anim_name)
	

func give_gold (amount):
	gold += amount
	ui.update_gold_text(gold)
	
func give_xp (amount):
	curXp += amount
	if curXp >= xpToNextLevel:
		level_up()
	ui.update_xp_bar(curXp, xpToNextLevel)
	
func level_up ():
	PlayerData.player_stats["Level"] += 1
	PlayerData.LoadStats()
	var overflowXp = curXp - xpToNextLevel
	xpToNextLevel *= xpToLevelIncreaseRate
	curXp = overflowXp
	ui.update_level_text(PlayerData.player_stats["Level"])
	ui.update_xp_bar(curXp, xpToNextLevel)
	stat_points += 5
	skill_points += 4
	print(stat_points, skill_points)
	character_sheet.LoadStats()
	character_sheet.LoadSkills()
	
func OnHeal(heal_amount):
	if health  + heal_amount >= PlayerData.player_stats["MaxHealth"]:
		health = PlayerData.player_stats["MaxHealth"]
	else:
		health += heal_amount
	var text = floating_text.instance()
	text.amount = heal_amount
	text.type = "Heal"
	add_child(text)
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
	
func take_damage (attack, critChance, critFactor):
	var dmgToTake = int(attack *0.5 - PlayerData.player_stats["Defense"]*0.25)
	var type
	var text = floating_text.instance()
	randomize()
	if randf() <=  PlayerData.player_stats["BlockChance"]:
		type = "Block"
		dmgToTake = 0
	elif randf() <= PlayerData.player_stats["DodgeChance"]:
		type = "Dodge"
		dmgToTake = 0
	elif randf() <= critChance:
		dmgToTake *= critFactor
		type = "Critical"
	else:
		type = "Damage"
	if dmgToTake < 0:
		dmgToTake = 0
	text.amount = dmgToTake
	text.type = type
	health -= int(dmgToTake)
	add_child(text)
	if health <= 0:
		die()
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
		
func die ():
	get_tree().reload_current_scene()
	
func _process (delta):
	if Input.is_action_just_pressed("interact"):
		try_interact()
	if Input.is_action_just_pressed("auto_attack"):
		auto_attack()
	if Input.is_action_just_pressed("tab_target"):
		tab_target()

func _input(event):
	if event is InputEventKey:
		if [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9].has(event.scancode) and event.is_pressed():
			var number = event.scancode -48
			if number == 1:
				selected_skill = "first"
				SkillLoop()
			if number == 2:
				selected_skill = "second"
				SkillLoop()
			if number == 3:
				selected_skill = "third"
				SkillLoop()
			if number == 4:
				selected_skill = "fourth"
				SkillLoop()
			if number == 5:
				selected_skill = "fifth"
				SkillLoop()
			if number == 6:
				selected_skill = "sixth"
				SkillLoop()

func try_interact ():
	rayCast.cast_to = facingDir * interactDist
	if rayCast.is_colliding():
		if rayCast.get_collider().has_method("on_interact"):
			rayCast.get_collider().on_interact(self)
			
func target_enemy (enemy):
	if targeted == enemy:
		enemy.get_node("AnimatedSprite").material.set_shader_param("outline_width", 0)
		targeted = null
	else:
		if targeted != null:
			targeted.get_node("AnimatedSprite").material.set_shader_param("outline_width", 0)
		targeted = enemy
		enemy.get_node("AnimatedSprite").material.set_shader_param("outline_width", 1)
		auto_attack()

func auto_attack ():
	if autoAttacking == false:
		autoAttacking = true
		yield(get_tree().create_timer(PlayerData.player_stats["AttackSpeed"]), "timeout")
		if targeted == null or position.distance_to(targeted.position) > attackDist:
			autoAttacking = false
		else:
			if position.distance_to(targeted.position) <= attackDist and targeted != null:
				animate_arms(autoAttacking, facingDir)
				targeted.take_damage(PlayerData.player_stats["PhysicalAttack"], PlayerData.player_stats["CriticalChance"], PlayerData.player_stats["CriticalFactor"])
				autoAttacking = false
				auto_attack()

func tab_target ():
	var current_enemy = null
	var distance = 300
	var at_least_one_in_range = false
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy.get_global_position().distance_to(get_global_position()) < distance:
			at_least_one_in_range = true
			if enemy in tabbed_enemies:
				pass
			else:
				current_enemy = enemy
				target_enemy(enemy)
				distance = enemy.get_global_position().distance_to(get_global_position())
	var length = tabbed_enemies.size()
	if current_enemy != null:
		tabbed_enemies.append(current_enemy)
	elif at_least_one_in_range:
		tabbed_enemies = []
		tab_target()

func animate_arms(autoAttacking, dir):
	if autoAttacking:
		if facingDir.x == 1:
			anim_arms.play("HitRight")
		elif facingDir.x == -1:
			anim_arms.play("HitLeft")
		elif facingDir.y == -1:
			anim_arms.play("HitUp")
		elif facingDir.y == 1:
			anim_arms.play("HitDown")
		
		

func next_auto() -> void:
	if targeted != null:
		if position.distance_to(targeted.position) <= attackDist and targeted != null:
			auto_attack()

func on_equipment_changed(equipment_slot, item_id):
	var texture
	var loaded_texture
	if item_id == null:
		texture = ImportData.naked_gear[equipment_slot]
	else:
		print(item_id)
		texture = ImportData.item_data[str(item_id)]["SpriteTexture"]
	if texture == null:
		pass
	else:
		loaded_texture = load("res://Sprites/" + texture + ".png")
		#Döp on_hand_sprite till equipment_slot-output för att matcha rätt.
		#använd get_node(child)

		print(equipment_slot)
		#Använd @ bara om det funkar
		var relevant_sprite = get_node("On" + equipment_slot + "Sprite")
		loaded_texture = load("res://Sprites/" + texture + ".png")
		print(relevant_sprite)
		print(loaded_texture)
		#var relevant_sprite = $OnHandSprite
		relevant_sprite.texture = loaded_texture
	#get_node(equipment_slot).set_texture(spritesheet)
	PlayerData.LoadStats()
