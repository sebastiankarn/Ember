extends KinematicBody2D

var floating_text = preload("res://FloatingText.tscn")
var user_name = "MangoPowder"
var profession = "Dragon Knight"
var stat_points = 3
var skill_points = 300
var health = 100
var mana = 100
var autoAttacking = false
var skill_Knight = false
var skill_Ninja = false
var skill_1A = false
var skill_1B = false
var skill_2A = false
var skill_2B = false
var skill_2C = false
var skill_2D = false
var skill_3A = false
var skill_3B = false
var skill_4A = false
var skill_4B = false
var rate_of_fire = 1
var casting = false
var player_selected_skill
var selected_skill_texture_button_node
var gold : int = 1000000
var curXp : int = 0
var xpToNextLevel : int = 70
var xpToLevelIncreaseRate : float = 1.8
var interactDist : int = 70
var vel = Vector2()
var facingDir = Vector2(0, 1)
var targeted = null
var walkingKeys = [0,0,0,0]
var attackDist : int = 60
var buffed = false
var eating = false
var drinking = false
var tabbed_enemies = []
onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite
onready var anim_arms = $AnimationArms
onready var ui = get_node("/root/MainScene/CanvasLayer/UI")
onready var enemy_ui = get_node("/root/MainScene/CanvasLayer/EnemyUI")
onready var end_scene = get_node("/root/MainScene/CanvasLayer/EndScene")
onready var health_bar = $HealthBar
onready var targetShader = preload("res://shaders/outline.shader")
onready var on_hand_sprite = $OnHandSprite
onready var character_sheet = get_node("/root/MainScene/CanvasLayer/CharacterSheet")
onready var cast_bar = get_node("/root/MainScene/CanvasLayer/CastBar")
onready var canvas_layer = get_node("/root/MainScene/CanvasLayer")
onready var main_hand_tween = get_node("/root/MainScene/CanvasLayer/SkillBar/Background/HBoxContainer/ShortCut1/TextureRect")
onready var inventory = get_node("/root/MainScene/CanvasLayer/Inventory")
var auto_attacking = false
var changeDir = false
var died = false
var auto_timer_ready = true
var last_clicked_pos = null
var hasSkillCursor = false
var spinGhost = preload("res://SpinGhost.tscn")
var walkingMarker = preload("res://WalkingMarker.tscn")

#Navigation
export var path_to_target := NodePath()
onready var _agent: NavigationAgent2D = $PlayerNavAgent
onready var _path_timer: Timer = $PathTimer
var _path : Array = []
var direction: Vector2 = Vector2.ZERO

func _ready():
	PlayerData.LoadStats()
	mana = PlayerData.player_stats["MaxMana"]
	health = PlayerData.player_stats["MaxHealth"]
	ui.update_level_text(PlayerData.player_stats["Level"])
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	ui.update_mana_bar(mana, PlayerData.player_stats["MaxMana"])
	ui.update_xp_bar(curXp, xpToNextLevel)
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_mana_updated(mana, PlayerData.player_stats["MaxMana"])
	checkAvailableQuests()
	
	#Pathfinding
	_update_pathfinding()
	_path_timer.connect("timeout", self, "_update_pathfinding")

func _update_pathfinding() -> void:
	if targeted != null && auto_attacking:
		_agent.set_target_location(targeted.position)
	elif last_clicked_pos != null:
		_agent.set_target_location(last_clicked_pos)
	
func get_player_rid() -> RID:
	return _agent.get_navigation_map()

func update_healthbars():
	ui.update_level_text(PlayerData.player_stats["Level"])
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	ui.update_mana_bar(mana, PlayerData.player_stats["MaxMana"])
	ui.update_xp_bar(curXp, xpToNextLevel)
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_mana_updated(mana, PlayerData.player_stats["MaxMana"])
	
func instance_ghost():
	var ghost = spinGhost.instance()
	ghost.global_position = global_position
	var animatedSprite = get_node("AnimatedSprite")
	ghost.texture = animatedSprite.get_sprite_frames().get_frame(animatedSprite.animation, animatedSprite.get_frame())
	get_parent().add_child(ghost)
	

func SkillLoop(texture_button_node):
	if player_selected_skill != null:
		var selected_skill = player_selected_skill
		casting = false
		if ImportData.skill_data[selected_skill].SkillType == "AutoAttack":
			auto_attacking = true
			return
		if texture_button_node.get_node("Sweep/Timer").time_left == 0 && mana >= ImportData.skill_data[selected_skill].SkillMana:
			casting = true
			cast_bar.use_castbar(ImportData.skill_data[selected_skill].SkillName, ImportData.skill_data[selected_skill].CastTime)
			yield(get_tree().create_timer(ImportData.skill_data[selected_skill].CastTime), "timeout")
			if cast_bar.cast_bar.value < 100 or cast_bar.label.text != ImportData.skill_data[selected_skill].SkillName:
				return
			casting = false
			mana -= ImportData.skill_data[selected_skill].SkillMana
			ui.update_mana_bar(mana, PlayerData.player_stats["MaxMana"])
			health_bar._on_mana_updated(mana, PlayerData.player_stats["MaxMana"])
			texture_button_node.start_cooldown()
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

				"Boomerang":
					var skill = load("res://BoomerangSkill.tscn")
					var skill_instance = skill.instance()
					skill_instance.skill_name = selected_skill
					skill_instance.rotation = get_angle_to(get_global_mouse_position())
					skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
					skill_instance.skill_range = ImportData.skill_data[selected_skill].SkillRange
					skill_instance.target = get_global_mouse_position()
					#Location to add
					get_parent().add_child(skill_instance)

				"RangedAOESkill":
					var skill = load("res://RangedAOESkill.tscn")
					var skill_instance = skill.instance()
					skill_instance.skill_name = selected_skill
					skill_instance.position = get_global_mouse_position()
					#Location to add
					get_parent().add_child(skill_instance)

				"Dash":
					var skill = load("res://DashSkill.tscn")
					var skill_instance = skill.instance()
					skill_instance.skill_name = selected_skill
					instance_ghost()
					get_node("GhostTimer").start()
					var tween = get_node("Tween")
					var target = get_global_mouse_position()
					var target_vector = target - position
					var skill_range = ImportData.skill_data[selected_skill].SkillRange
					var new_vector = target_vector.normalized()
					new_vector *= skill_range
					if target_vector.length() > skill_range:
						target = position + new_vector
					var raycast = get_node("SpellRaycast")
					raycast.cast_to = new_vector
					raycast.force_raycast_update()
					if raycast.is_colliding():
						if "Tile" in str(raycast.get_collider()):
							target = raycast.get_collision_point()
					skill_instance.position = target
					yield(get_tree().create_timer(0.3), "timeout")
					#Location to add
					if skill_3B:
						get_parent().add_child(skill_instance)
					#Använd apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))
					tween.interpolate_property(self, "position", position, target, 0.5)#, tween.TRANS_CUBIC, tween.EASE_IN)
					tween.start()
					yield(get_tree().create_timer(0.5), "timeout")
					get_node("GhostTimer").stop()

				"BackStab":
					if targeted != null and targeted.get_global_position().distance_to(get_global_position()) < ImportData.skill_data[selected_skill].SkillRange:
						instance_ghost()
						var blood = load("res://Blood.tscn")
						var target = targeted.get_global_position()
						var target_vector = target - position
						var new_vector = target_vector.normalized()
						var new_position = target + new_vector*30
						position = new_position
						self.modulate = Color(0,0,0)
						var tween = get_tree().create_tween()
						tween.tween_property(self, "modulate", Color(1,1,1), 0.5)
						var blood_instance = blood.instance()
						blood_instance.position = targeted.position
						blood_instance.rotation = targeted.position.angle_to_point(position)
						get_tree().current_scene.add_child(blood_instance)
						targeted.take_damage(1.5*PlayerData.player_stats["PhysicalAttack"], PlayerData.player_stats["CriticalChance"], PlayerData.player_stats["CriticalFactor"], true)

				"ExpandingAOESkill":
					var skill = load("res://ExpandingAOESkill.tscn")
					var skill_instance = skill.instance()
					skill_instance.skill_name = selected_skill
					skill_instance.position = get_global_position()
					#add child to map scene
					get_parent().add_child(skill_instance)
					
				"AOESkill":
					var skill = load("res://AOESkill.tscn")
					var skill_instance = skill.instance()
					skill_instance.skill_name = selected_skill
					skill_instance.position = get_global_position()
					#add child to map scene
					get_parent().add_child(skill_instance)

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
						skill_instance.get_node("Light2D").color = Color("6ae7f0")
						skill_instance.skill_name = selected_skill
						skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
						skill_instance.rotation = get_angle_to(targeted.get_global_position())
						#Location to add
						get_parent().add_child(skill_instance)

				"Bubble":
					var skill = load("res://BubbleSkill.tscn")
					var skill_instance = skill.instance()
					skill_instance.skill_name = selected_skill
					#Location to add
					add_child(skill_instance)
					yield(get_tree().create_timer(ImportData.skill_data[selected_skill].SkillDuration), "timeout")
					#Om det ska smälla
					var skill2 = load("res://ExpandingAOESkill.tscn")
					var skill_instance2 = skill2.instance()
					skill_instance2.skill_name = "10004"
					skill_instance2.position = get_global_position()
					#add child to map scene
					get_parent().add_child(skill_instance2)

				"Buff":
					casting = false
					if !buffed:
						if ImportData.skill_data[selected_skill].SkillName == "Fire Buff":
							buffed = true
							PlayerData.player_stats["Strength"] += 10
							PlayerData.player_stats["Defense"] += 50
							PlayerData.LoadStats()
							get_node("OnMainHandSprite/Fire").restart()
							get_node("OnMainHandSprite/Fire").visible = true
							if get_node("OnOffHandSprite").texture != null:
								get_node("OnOffHandSprite/Fire").restart()
								get_node("OnOffHandSprite/Fire").visible = true
							yield(get_tree().create_timer(ImportData.skill_data[selected_skill].SkillDuration), "timeout")
							PlayerData.player_stats["Strength"] -= 10
							PlayerData.player_stats["Defense"] -= 50
							PlayerData.LoadStats()
							get_node("OnMainHandSprite/Fire").visible = false
							get_node("OnOffHandSprite/Fire").visible = false
							buffed = false
							return
						elif ImportData.skill_data[selected_skill].SkillName  == "Shadow Buff":
							buffed = true
							PlayerData.player_stats["Dexterity"] += 10
							PlayerData.player_stats["AttackSpeed"] += 1
							PlayerData.LoadStats()
							get_node("PurpleShadow").restart()
							get_node("PurpleShadow").visible = true
							goDark(ImportData.skill_data[selected_skill].SkillDuration)
							yield(get_tree().create_timer(ImportData.skill_data[selected_skill].SkillDuration), "timeout")
							PlayerData.player_stats["Dexterity"] -= 10
							PlayerData.player_stats["AttackSpeed"] -= 1
							PlayerData.LoadStats()
							get_node("PurpleShadow").visible = false
							buffed = false
							return
						elif ImportData.skill_data[selected_skill].SkillName  == "Electric Ball":
							buffed = true
							PlayerData.player_stats["MovementSpeed"] += 500
							PlayerData.LoadStats()
							get_node("AnimatedSprite/Shadow").restart()
							get_node("AnimatedSprite/Shadow").visible = true
							yield(get_tree().create_timer(ImportData.skill_data[selected_skill].SkillDuration), "timeout")
							PlayerData.player_stats["MovementSpeed"] -= 500
							PlayerData.LoadStats()
							buffed = false
							return
					else:
						return
			casting = false

func goDark(duration):
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	var tween4 = get_tree().create_tween()
	tween1.tween_property(get_node("OnMainHandSprite"), "modulate", Color(0.4,0.4,0.4), 0.3)
	tween2.tween_property(get_node("OnOffHandSprite"), "modulate", Color(0.4,0.4,0.4), 0.3)
	tween3.tween_property(get_node("AnimatedSprite"), "modulate", Color(0.4,0.4,0.4), 0.3)
	tween4.tween_property(get_node("Arms"), "modulate", Color(0.4,0.4,0.4), 0.3)
	yield(get_tree().create_timer(duration), "timeout")
	var tween5 = get_tree().create_tween()
	var tween6 = get_tree().create_tween()
	var tween7 = get_tree().create_tween()
	var tween8 = get_tree().create_tween()
	tween5.tween_property(get_node("OnMainHandSprite"), "modulate", Color(1,1,1), 0.3)
	tween6.tween_property(get_node("OnOffHandSprite"), "modulate", Color(1,1,1), 0.3)
	tween7.tween_property(get_node("AnimatedSprite"), "modulate", Color(1,1,1), 0.3)
	tween8.tween_property(get_node("Arms"), "modulate", Color(1,1,1), 0.3)

func _physics_process(delta):
	if targeted != null && auto_attacking:
		last_clicked_pos = null
		navigate_to_target(targeted.position)
	elif last_clicked_pos != null:
		navigate_to_target(last_clicked_pos)

func navigate_to_target(target_position):
	var is_autoattack = false

	# Calculate direction directly towards the target_position
	direction = position.direction_to(target_position).normalized()

	var dist = position.distance_to(target_position)

	# Determine the predominant direction for animations
	if abs(direction.x) > abs(direction.y):
		facingDir = Vector2(sign(direction.x), 0)
	else:
		facingDir = Vector2(0, sign(direction.y))

	# Check for auto-attacking range
	if targeted != null and auto_attacking:
		if dist > attackDist:
			# If the distance is greater than the attack distance, continue moving towards the target
			vel = direction * PlayerData.player_stats["MovementSpeed"]
		else:
			# If within attack distance, stop moving and set the velocity to zero
			vel = Vector2.ZERO
			is_autoattack = true
	else:
		# If not auto-attacking, continue moving normally towards the target
		vel = direction * PlayerData.player_stats["MovementSpeed"]

	# Stop movement if close enough to the clicked position
	if dist <= 5: 
		last_clicked_pos = null
		vel = Vector2.ZERO 

	move_and_slide(vel, Vector2.ZERO)
	manage_animations()

	if is_autoattack:
		auto_attack()

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


func play_animation(anim_name):
	if anim.animation != anim_name:
		anim.play(anim_name)
		anim_arms.playback_speed = 1
		anim_arms.play(anim_name)

	
func give_gold (amount):
	gold += amount
	inventory.update_inventory_gold()
	
func loot_item(item, stack):
	var item_id = null
	if stack != null:
		item_id = str(item)
	else:
		item_id = str(item["item_id"])
	var item_name = ImportData.item_data[str(item_id)]["Name"]
	var icon_texture = load("res://Sprites/Icon_Items/" + item_name + ".png")
	var data = {}
	data["original_item_id"] = item_id
	if stack != null:
		data["original_stackable"] = true
		data["original_stack"] = stack
		data["original_info"] = null
		data["original_stats"] = null
	else:
		data["original_stackable"] = false
		data["original_stack"] = 1
		data["original_info"] = item
		data["original_stats"] = null
	data["original_texture"] = icon_texture
	data["original_stats"] = {}
	clone_dict(ImportData.item_data[item_id], data["original_stats"])

	var target_inv_slot
	
	#Om det redan finns en stack
	if data["original_stackable"]:
		for inventory_slot in PlayerData.inv_data:
			if PlayerData.inv_data[inventory_slot]["Item"] == data["original_item_id"]:
				var inv_stack_node = get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer/" + inventory_slot + "/Stack")
				PlayerData.inv_data[inventory_slot]["Stack"] += stack
				inv_stack_node.set_text(str(PlayerData.inv_data[inventory_slot]["Stack"]))
				canvas_layer.LoadShortCuts()
				return
	
	for inventory_slot in PlayerData.inv_data:
		if PlayerData.inv_data[inventory_slot]["Item"] == null:
			target_inv_slot = inventory_slot
			break

	if target_inv_slot != null:
		PlayerData.inv_data[target_inv_slot]["Item"] = data["original_item_id"]
		var inv_node = get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer/" + target_inv_slot + "/Icon")
		var inv_stack_node = get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer/" + target_inv_slot + "/Stack")
		inv_node.texture = data["original_texture"]
		inv_node.get_node("Sweep").texture_progress = data["original_texture"]
		inv_node.get_node("Sweep/Timer").wait_time = 20
		PlayerData.inv_data[target_inv_slot]["Stack"] = data["original_stack"]
		PlayerData.inv_data[target_inv_slot]["Info"] = data["original_info"]
		if data["original_info"] != null:
			for stat in ImportData.item_data[item_id]:
				if stat in data["original_info"]:
					if data["original_info"][stat] < 1:
						data["original_stats"][stat] = stepify(data["original_info"][stat], 0.01)
					else:
						data["original_stats"][stat] = int(round(data["original_info"][stat]))
			
			if data["original_info"]["magical"]:
				if data["original_info"]["prefix"]:
					var prefix_value = data["original_info"][data["original_info"]["prefix"]]
					if prefix_value < 1:
						prefix_value = stepify(prefix_value, 0.01)
					else:
						prefix_value = int(round(prefix_value))
					if data["original_stats"][ImportData.magical_properties_data[data["original_info"]["prefix"]]["MagicalStatName"]] != null:
						data["original_stats"][ImportData.magical_properties_data[data["original_info"]["prefix"]]["MagicalStatName"]] += prefix_value
					else:
						data["original_stats"][ImportData.magical_properties_data[data["original_info"]["prefix"]]["MagicalStatName"]] = prefix_value
				if data["original_info"]["suffix"]:
					var suffix_value = data["original_info"][data["original_info"]["suffix"]]
					if suffix_value < 1:
						suffix_value = stepify(suffix_value, 0.01)
					else:
						suffix_value = int(round(suffix_value))
					if data["original_stats"][ImportData.magical_properties_data[data["original_info"]["suffix"]]["MagicalStatName"]] != null:
						data["original_stats"][ImportData.magical_properties_data[data["original_info"]["suffix"]]["MagicalStatName"]] += suffix_value
					else:
						data["original_stats"][ImportData.magical_properties_data[data["original_info"]["suffix"]]["MagicalStatName"]] = suffix_value
		PlayerData.inv_data[target_inv_slot]["Stats"] = data["original_stats"]
		if stack == null:
			inv_stack_node.set_text("")
		else:
			if stack == 1:
				inv_stack_node.set_text("")
			else:
				inv_stack_node.set_text(str(stack))
	else:
		print("BACKPACK FULL")	
	canvas_layer.LoadShortCuts()
	
func clone_dict(source, target):
	for key in source:
		target[key] = source[key]

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
	stat_points += 2
	skill_points += 4
	character_sheet.LoadStats()
	character_sheet.LoadSkills()
	canvas_layer.LoadShortCuts()
	character_sheet.set_personal_data()
	OnHeal(PlayerData.player_stats["MaxHealth"])
	get_node("TextureRect").show()
	var tween = get_node("TextureRect/Tween")
	tween.interpolate_property(tween.get_parent(), 'rect_scale', Vector2(0, 0), Vector2(1, 1), 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.interpolate_property(tween.get_parent(), 'rect_scale', Vector2(1, 1), Vector2(0, 0), 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.3)
	tween.start()
	yield(get_tree().create_timer(0.6), "timeout")
	get_node("TextureRect").hide()
	
	
	#hur mkt som ska healas, tiden heal sker, om det är mat eller inte

func heal_over_time(heal_amount, time, food):
	var tick_heal = float(heal_amount) / time
	tick_heal = int(tick_heal)
	if food:
		for n in time:
			yield(get_tree().create_timer(1), "timeout")
			OnHeal(tick_heal)
		eating = false
	else:
		for n in time:
			yield(get_tree().create_timer(1), "timeout")
			OnHeal(tick_heal)
	
func OnHeal(heal_amount):
	if health  + heal_amount >= PlayerData.player_stats["MaxHealth"]:
		health = PlayerData.player_stats["MaxHealth"]
	else:
		health += heal_amount
	var text = floating_text.instance()
	text.amount = heal_amount
	text.type = "Heal"
	text.set_position(position)
	get_tree().get_root().add_child(text)
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
	
func take_damage_over_time(damage_amount, time, type):
	var tick_damage = float(damage_amount) / time
	tick_damage = int(tick_damage)
	get_node("Fire").visible = true
	for n in time:
		yield(get_tree().create_timer(1), "timeout")
		take_damage(tick_damage, 0, 0, true)
		if died:
			break
	get_node("Fire").visible = false
	died = false
	
func mana_boost(mana_amount):
	if mana  + mana_amount >= PlayerData.player_stats["MaxMana"]:
		mana = PlayerData.player_stats["MaxMana"]
	else:
		mana += mana_amount
	var text = floating_text.instance()
	text.amount = mana_amount
	text.type = "Mana"
	text.set_position(position)
	get_tree().get_root().add_child(text)
	ui.update_mana_bar(mana, PlayerData.player_stats["MaxMana"])
	health_bar._on_mana_updated(mana, PlayerData.player_stats["MaxMana"])
	
func mana_over_time(mana_amount, time, drink):
	var tick_mana = float(mana_amount) / time
	tick_mana = int(tick_mana)
	if drink:
		for n in time:
			yield(get_tree().create_timer(1), "timeout")
			mana_boost(tick_mana)
		drinking = false
	else:
		for n in time:
			yield(get_tree().create_timer(1), "timeout")
			OnHeal(tick_mana)
	
func take_damage (attack, critChance, critFactor, in_range):
	var dmgToTake = attack*(float(50)/(50 + PlayerData.player_stats["Defense"]))
	var type
	var text = floating_text.instance()
	randomize()
	if randf() <=  PlayerData.player_stats["BlockChance"]:
		type = "Block"
		dmgToTake *= 0.5
		var second_text = floating_text.instance()
		second_text.amount = -1
		second_text.type = "Block"
		second_text.set_position(position)
		get_tree().get_root().add_child(second_text)
	elif randf() <= PlayerData.player_stats["DodgeChance"]:
		type = "Dodge"
		dmgToTake = 0
	elif randf() <= critChance:
		dmgToTake *= critFactor
		type = "Critical"
	else:
		type = "Damage"
	var rng = RandomNumberGenerator.new()
	dmgToTake *= rng.randf_range(0.5, 1.5)
	rng.randomize()
	if dmgToTake <= 0 && type != "Dodge":
		dmgToTake = 1
	text.amount = int(dmgToTake)
	text.type = type
	health -= int(dmgToTake)
	text.set_position(position)
	get_tree().get_root().add_child(text)
	if health <= 0:
		health = 0
		ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
		health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"]) 
		die()
	else:
		ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
		health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
		
func die ():
	died = true
	end_scene.show()
	get_tree().paused = true
	
func reset_player():
	if targeted != null:
		targeted.get_node("AnimatedSprite").material.set_shader_param("outline_width", 1)
		targeted.get_node("AnimatedSprite").material.set_shader_param("outline_color", Color('353540'))
	health = 20
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
	self.global_position = Vector2(569, 451)
	enemy_ui.hide()
	auto_attacking = false
	targeted = null

	
func _process (delta):
	if Input.is_action_just_pressed("interact"):
		try_interact()
	if Input.is_action_just_pressed("tab_target"):
		tab_target()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_RIGHT:
				var walkingMarkerInstance = walkingMarker.instance()
				walkingMarkerInstance.position = get_global_mouse_position()
				get_parent().add_child(walkingMarkerInstance)
				auto_attacking = false
				last_clicked_pos = get_global_mouse_position()
	
	if event.is_action_pressed("ui_cancel"):
		if targeted != null:
			targeted.get_node("AnimatedSprite").material.set_shader_param("outline_width", 1)
			targeted.get_node("AnimatedSprite").material.set_shader_param("outline_color", Color('353540'))
			targeted = null
			enemy_ui.hide()
			auto_attacking = false


func _input(event):
	if event is InputEventMouseButton and event.pressed and hasSkillCursor:
		match event.button_index:
			BUTTON_LEFT:
				SkillLoop(selected_skill_texture_button_node)
				canvas_layer.get_node("MouseCursorSkill").reset_cursor()
				get_node("SkillRangeNode").hide()
				yield(get_tree().create_timer(0.2), "timeout")
				hasSkillCursor = false

	if event is InputEventKey:
		if [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9].has(event.scancode) and event.is_pressed():
			var number = event.scancode -48
			canvas_layer.SelectShortcut("ShortCut" + str(number))
		

func try_interact ():
	rayCast.cast_to = facingDir * interactDist
	rayCast.force_raycast_update()
	if rayCast.is_colliding():
		if rayCast.get_collider().has_method("on_interact"):
			rayCast.get_collider().on_interact(self)
			
func target_enemy (enemy):
	if targeted == enemy:
		enemy.get_node("AnimatedSprite").material.set_shader_param("outline_width", 1)
		enemy.get_node("AnimatedSprite").material.set_shader_param("outline_color", Color('353540'))
		targeted = null
		enemy_ui.hide()
	else:
		if targeted != null:
			targeted.get_node("AnimatedSprite").material.set_shader_param("outline_width", 1)
			targeted.get_node("AnimatedSprite").material.set_shader_param("outline_color", Color('353540'))
		targeted = enemy
		enemy.get_node("AnimatedSprite").material.set_shader_param("outline_width", 2)
		enemy.get_node("AnimatedSprite").material.set_shader_param("outline_color", Color('f00d0d'))
		enemy_ui.load_ui(enemy)

func auto_attack():
	if autoAttacking == false:
		autoAttacking = true
		main_hand_tween.visible = true
		if targeted == null or position.distance_to(targeted.position) > attackDist:
			main_hand_tween.visible = false
			autoAttacking = false
		else:
			if position.distance_to(targeted.position) <= attackDist and targeted != null:
				animate_arms(autoAttacking, facingDir)
				cast_bar.use_castbar("Auto attack", get_node("AutoTimer").time_left)
				yield(get_tree().create_timer(get_node("AutoTimer").time_left), "timeout")
				main_hand_tween.visible = false
				autoAttacking = false
				auto_attack()

func deal_damage_from_auto():
	if targeted != null:
		var in_range = position.distance_to(targeted.position) < attackDist
		targeted.take_damage(PlayerData.player_stats["PhysicalAttack"], PlayerData.player_stats["CriticalChance"], PlayerData.player_stats["CriticalFactor"], in_range)
		get_node("AutoTimer").start(1.0/(PlayerData.player_stats["AttackSpeed"]))

func tab_target():
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
	var attackSpeed = PlayerData.player_stats["AttackSpeed"]
	anim_arms.playback_speed = attackSpeed
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
		texture = ImportData.item_data[str(item_id)]["SpriteTexture"]
	if texture == null:
		if equipment_slot == "MainHand":
			get_node("OnMainHandSprite").set_texture(null)
		if equipment_slot == "OffHand":
			get_node("OnOffHandSprite").set_texture(null)
		pass
	else:
		loaded_texture = load("res://Sprites/" + texture + ".png")
		#Döp on_hand_sprite till equipment_slot-output för att matcha rätt.
		#använd get_node(child)

		#Använd @ bara om det funkar
		var relevant_sprite = get_node("On" + equipment_slot + "Sprite")
		loaded_texture = load("res://Sprites/" + texture + ".png")
		
		#var relevant_sprite = $OnHandSprite
		relevant_sprite.texture = loaded_texture
	#get_node(equipment_slot).set_texture(spritesheet)
	PlayerData.LoadStats()

func _on_AutoTimer_timeout():
	auto_timer_ready = true

func _on_GhostTimer_timeout():
	instance_ghost()

func showSkillRange(skill_range):
	var skillRangeNode = get_node("SkillRangeNode")
	skillRangeNode.radius = skill_range
	skillRangeNode._draw()
	skillRangeNode.show()

func checkAvailableQuests():
	var current_level = PlayerData.player_stats["Level"]
	for i in ImportData.quest_data.keys():
		if ImportData.quest_data[i]["Npc"] != null:
			var required_level = ImportData.quest_data[i]["AvailableReqirements"]["PlayerLevel"]
			var required_completed_quests = ImportData.quest_data[i]["AvailableReqirements"]["CompletedQuests"]
			if required_level <= current_level:
				var completed_required_quests = checkRequiredQuests(required_completed_quests) 
				#Quest available
				if completed_required_quests:
					var quest_id = i
					var player_quest_data = PlayerData.quest_data[str(i)]
					var quest_accepted = player_quest_data["Accepted"]
					var quest_abandoned = player_quest_data["Abandoned"]
					var quest_completed = player_quest_data["Completed"]
					var requirements_met
					if(!quest_accepted and !quest_abandoned and !quest_completed):
						#Show quest available
						print("QUEST AVAILABLE! " + quest_id)
						

func checkRequiredQuests(required_completed_quests):
	if(required_completed_quests == null):
		return true
	var required_quests = required_completed_quests.split(",")
	for i in required_quests:
		var required_quest_id = i
		var completed = PlayerData.quest_data[required_quest_id]["Completed"]
		if (!completed):
			return false
	return true
