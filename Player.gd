extends CharacterBody2D

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
var gold : int = 0
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
@onready var rayCast = $RayCast2D
@onready var interactCollision = get_node("InteractArea2D/InteractCollision")
@onready var anim = $PlayerAnimationPlayer
#@onready var anim_arms = $PlayerAnimationPlayer
@onready var ui = get_node("/root/MainScene/CanvasLayer/UI")
@onready var interact_text = get_node("/root/MainScene/CanvasLayer/InteractText")
@onready var enemy_ui = get_node("/root/MainScene/CanvasLayer/EnemyUI")
@onready var end_scene = get_node("/root/MainScene/CanvasLayer/EndScene")
@onready var health_bar = $HealthBar
@onready var targetShader = preload("res://shaders/outline.gdshader")
@onready var character_sheet = get_node("/root/MainScene/CanvasLayer/CharacterSheet")
@onready var cast_bar = get_node("/root/MainScene/CanvasLayer/CastBar")
@onready var canvas_layer = get_node("/root/MainScene/CanvasLayer")
@onready var main_hand_glow = get_node("/root/MainScene/CanvasLayer/SkillBar/Background/HBoxContainer/ShortCut1/TextureRect")
@onready var inventory = get_node("/root/MainScene/CanvasLayer/Inventory")
@onready var quest_log = get_node("/root/MainScene/CanvasLayer/QuestLog")
@onready var npc_quest_window = get_node("/root/MainScene/CanvasLayer/NpcQuestWindow")
@onready var darkenShader = preload("res://shaders/darken.gdshader")
var auto_attacking = false
var changeDir = false
var died = false
var auto_timer_ready = true
var last_clicked_pos = null
var hasSkillCursor = false
var spinGhost = preload("res://SpinGhost.tscn")
var shadowGhost = preload("res://ShadowGhost.tscn")
var walkingMarker = preload("res://WalkingMarker.tscn")
var ranged_auto = false
var interactables = []

#Navigation
@export var path_to_target := NodePath()
@onready var _agent: NavigationAgent2D = $PlayerNavAgent
@onready var _path_timer: Timer = $PathTimer
#var _path : Array = []
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
	_path_timer.connect("timeout", Callable(self, "_update_pathfinding"))

func _update_pathfinding() -> void:
	if targeted != null && auto_attacking:
		_agent.set_target_position(targeted.position)
	elif last_clicked_pos != null:
		_agent.set_target_position(last_clicked_pos)

func get_player_rid() -> RID:
	return _agent.get_navigation_map()

func update_healthbars():
	if health > PlayerData.player_stats["MaxHealth"]:
		health = PlayerData.player_stats["MaxHealth"]
	if mana > PlayerData.player_stats["MaxMana"]:
		mana = PlayerData.player_stats["MaxMana"]
	ui.update_level_text(PlayerData.player_stats["Level"])
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	ui.update_mana_bar(mana, PlayerData.player_stats["MaxMana"])
	ui.update_xp_bar(curXp, xpToNextLevel)
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_mana_updated(mana, PlayerData.player_stats["MaxMana"])

func instance_ghost():
	var ghost = spinGhost.instantiate()
	ghost.global_position = global_position
	var player_sprite_2d = get_node("PlayerSprite2D")
	ghost.texture = player_sprite_2d.get_texture()
	ghost.vframes = player_sprite_2d.vframes
	ghost.hframes = player_sprite_2d.hframes
	ghost.frame = player_sprite_2d.frame
	ghost.scale = self.scale
	#ghost.texture = animatedSprite.get_sprite_frames().get_frame(animatedSprite.animation, animatedSprite.get_frame())
	get_parent().add_child(ghost)

func instance_shadow():
	var ghost = shadowGhost.instantiate()
	ghost.global_position = global_position
	var player_sprite_2d = get_node("PlayerSprite2D")
	ghost.texture = player_sprite_2d.get_texture()
	ghost.vframes = player_sprite_2d.vframes
	ghost.hframes = player_sprite_2d.hframes
	ghost.frame = player_sprite_2d.frame
	ghost.scale = self.scale
	#ghost.texture = animatedSprite.get_sprite_frames().get_frame(animatedSprite.animation, animatedSprite.get_frame())
	get_parent().add_child(ghost)

func SkillLoop(texture_button_node):
	if player_selected_skill != null:
		var selected_skill = player_selected_skill
		casting = false
		if ImportData.skill_data[selected_skill].SkillType == "AutoAttack":
			auto_attacking = true
			return
		if texture_button_node.get_node("Sweep/Timer").time_left == 0 && mana >= ImportData.skill_data[selected_skill].SkillMana:
			if ImportData.skill_data[selected_skill].TargetNeeded:
				if targeted == null:
					print("NO TARGET")
					return
				else:
					if position.distance_to(targeted.position) >= ImportData.skill_data[selected_skill].SkillRange:
						print("NOT IN RANGE")
						return
			casting = true
			cast_bar.use_castbar(ImportData.skill_data[selected_skill].SkillName, ImportData.skill_data[selected_skill].CastTime)
			await get_tree().create_timer(ImportData.skill_data[selected_skill].CastTime).timeout
			if cast_bar.label.text != ImportData.skill_data[selected_skill].SkillName:
				return
			casting = false
			mana -= ImportData.skill_data[selected_skill].SkillMana
			ui.update_mana_bar(mana, PlayerData.player_stats["MaxMana"])
			health_bar._on_mana_updated(mana, PlayerData.player_stats["MaxMana"])
			texture_button_node.start_cooldown()
			casting = true
			get_node("TurnAxis").rotation = get_angle_to(get_global_mouse_position())
			match ImportData.skill_data[selected_skill].SkillType:

				"RangedSingleTargetSkill":
					var skill = load("res://RangedSingleTargetSkill.tscn")
					var skill_instance = skill.instantiate()
					skill_instance.skill_name = selected_skill
					skill_instance.caster = self
					skill_instance.rotation = get_angle_to(get_global_mouse_position())
					skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
					#Location to add
					get_parent().add_child(skill_instance)

				"Boomerang":
					var skill = load("res://BoomerangSkill.tscn")
					var skill_instance = skill.instantiate()
					skill_instance.skill_name = selected_skill
					skill_instance.caster = self
					skill_instance.rotation = get_angle_to(get_global_mouse_position())
					skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
					skill_instance.skill_range = ImportData.skill_data[selected_skill].SkillRange
					skill_instance.target = get_global_mouse_position()
					#Location to add
					get_parent().add_child(skill_instance)

				"RangedAOESkill":
					var skill = load("res://RangedAOESkill.tscn")
					var skill_instance = skill.instantiate()
					skill_instance.skill_name = selected_skill
					skill_instance.position = get_global_mouse_position()
					#Location to add
					get_parent().add_child(skill_instance)

				"Dash":
					#Stop walking towards last click
					var auto_attacking_before = auto_attacking
					auto_attacking = false
					last_clicked_pos = null
					
					var target = get_global_mouse_position()
					var skill = load("res://DashSkill.tscn")
					var skill_instance = skill.instantiate()
					skill_instance.skill_name = selected_skill
					instance_ghost()
					get_node("GhostTimer").start()
					var target_vector = target - position
					var skill_range = ImportData.skill_data[selected_skill].SkillRange
					var new_vector = target_vector.normalized()
					if target_vector.x > 1:
						play_animation("dash_right")
					else:
						play_animation("dash_left")
					new_vector *= skill_range
					if target_vector.length() > skill_range:
						target = position + new_vector
					var raycast = get_node("SpellRaycast")
					raycast.target_position = new_vector
					raycast.force_raycast_update()
					if raycast.is_colliding():
						if "Tile" in str(raycast.get_collider()):
							target = raycast.get_collision_point()
					skill_instance.position = target
					#await get_tree().create_timer(0.3).timeout
					#Location to add
					#if skill_3B:
					#	get_parent().add_child(skill_instance)
					#Använd apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))
					var tween = create_tween()
					tween.tween_property(self, "position", target, 0.2).set_trans(tween.TRANS_CUBIC).set_ease(tween.EASE_IN)
					await get_tree().create_timer(0.2).timeout
					if auto_attacking_before and targeted != null and position.distance_to(targeted.position) < 10:
						auto_attacking = true
							
					if skill_3B:
						get_parent().add_child(skill_instance)
					get_node("GhostTimer").stop()

				"BackStab":
					if targeted != null and targeted.get_global_position().distance_to(get_global_position()) < ImportData.skill_data[selected_skill].SkillRange:
						instance_shadow()
						var blood = load("res://BloodParticles.tscn")
						var target = targeted.get_global_position()
						var target_vector = target - position
						var new_vector = target_vector.normalized()
						var new_position = target + new_vector*30
						position = new_position
						self.modulate = Color(0,0,0)
						var tween = create_tween()
						tween.tween_property(self, "modulate", Color(1,1,1), 0.5)
						var blood_instance = blood.instantiate()
						blood_instance.position = targeted.position
						blood_instance.rotation = targeted.position.angle_to_point(position)
						get_tree().current_scene.add_child(blood_instance)
						targeted.take_damage(1.5*PlayerData.player_stats["PhysicalAttack"], PlayerData.player_stats["CriticalChance"], PlayerData.player_stats["CriticalFactor"], true)

				"ExpandingAOESkill":
					var skill = load("res://ExpandingAOESkill.tscn")
					var skill_instance = skill.instantiate()
					skill_instance.skill_name = selected_skill
					skill_instance.position = get_global_position()
					#add child to map scene
					get_parent().add_child(skill_instance)

				"AOESkill":
					var skill = load("res://AOESkill.tscn")
					var skill_instance = skill.instantiate()
					skill_instance.skill_name = selected_skill
					skill_instance.position = get_global_position()
					#add child to map scene
					get_parent().add_child(skill_instance)

				"SingleTargetHeal":
					var skill = load("res://SingleTargetHeal.tscn")
					var skill_instance = skill.instantiate()
					skill_instance.skill_name = selected_skill
					#Location to add
					add_child(skill_instance)

				"RangedSingleTargetTargetedSkill":
					if targeted != null and targeted.get_global_position().distance_to(get_global_position()) < ImportData.skill_data[selected_skill].SkillRange:
						get_node("TurnAxis").rotation = get_angle_to(targeted.get_global_position())
						var skill = load("res://RangedSingleTargetTargetedSkill.tscn")
						var skill_instance = skill.instantiate()
						skill_instance.get_node("PointLight2D").color = Color("6ae7f0")
						skill_instance.skill_name = selected_skill
						skill_instance.caster = self
						skill_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
						skill_instance.rotation = get_angle_to(targeted.get_global_position())
						#Location to add
						get_parent().add_child(skill_instance)

				"Bubble":
					var skill = load("res://BubbleSkill.tscn")
					var skill_instance = skill.instantiate()
					skill_instance.skill_name = selected_skill
					#Location to add
					add_child(skill_instance)
					await get_tree().create_timer(ImportData.skill_data[selected_skill].SkillDuration).timeout
					#Om det ska smälla
					var skill2 = load("res://ExpandingAOESkill.tscn")
					var skill_instance2 = skill2.instantiate()
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
							await get_tree().create_timer(ImportData.skill_data[selected_skill].SkillDuration).timeout
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
							PlayerData.player_stats["AttackSpeed"] += 0.01
							PlayerData.LoadStats()
							get_node("PurpleShadow").restart()
							get_node("PurpleShadow").visible = true
							goDark(ImportData.skill_data[selected_skill].SkillDuration)
							await get_tree().create_timer(ImportData.skill_data[selected_skill].SkillDuration).timeout
							PlayerData.player_stats["Dexterity"] -= 10
							PlayerData.player_stats["AttackSpeed"] -= 0.01
							PlayerData.LoadStats()
							get_node("PurpleShadow").visible = false
							buffed = false
							return
						elif ImportData.skill_data[selected_skill].SkillName  == "Electric Ball":
							buffed = true
							PlayerData.player_stats["MovementSpeed"] += 500
							PlayerData.LoadStats()
							get_node("AnimatedSprite2D/Shadow").restart()
							get_node("AnimatedSprite2D/Shadow").visible = true
							await get_tree().create_timer(ImportData.skill_data[selected_skill].SkillDuration).timeout
							PlayerData.player_stats["MovementSpeed"] -= 500
							PlayerData.LoadStats()
							buffed = false
							return
					else:
						return
			casting = false

func resetAnimAfterDash():
	if anim.current_animation == "dash_right":
		play_animation("idle_right")
	if anim.current_animation == "dash_left":
		play_animation("idle_left")

func goDark(duration):
	var tween1 = create_tween()
	var tween2 = create_tween()
	var main_hand_modulate = get_node("OnMainHandSprite").modulate
	var off_hand_modulate = get_node("OnOffHandSprite").modulate
	var old_shader = get_node("PlayerSprite2D").material.shader
	get_node("PlayerSprite2D").material.shader = darkenShader
	get_node("PlayerSprite2D").material.set_shader_parameter("darken", true)
	tween1.tween_property(get_node("OnMainHandSprite"), "modulate", Color(0.4,0.4,0.4), 0.3)
	tween2.tween_property(get_node("OnOffHandSprite"), "modulate", Color(0.4,0.4,0.4), 0.3)
	await get_tree().create_timer(duration).timeout
	var tween5 = create_tween()
	var tween6 = create_tween()
	tween5.tween_property(get_node("OnMainHandSprite"), "modulate", main_hand_modulate, 0.3)
	tween6.tween_property(get_node("OnOffHandSprite"), "modulate", off_hand_modulate, 0.3)
	get_node("PlayerSprite2D").material.shader = old_shader

func _physics_process(_delta):
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
	facingDir = Vector2(sign(direction.x), 0)

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

	set_velocity(vel)
	set_up_direction(Vector2.UP)
	move_and_slide()
	manage_animations()

	if is_autoattack:
		auto_attacking = false
		auto_attack()

func manage_animations():
	if vel == Vector2.ZERO:
		if facingDir.x == 1:
			play_animation("idle_right")
		else:
			play_animation("idle_left")

	else:
		if vel.x > 0:
			play_animation("run_right")
		else:
			play_animation("run_left")


func play_animation(anim_name):
	
	if anim.current_animation != anim_name:
		anim.play(anim_name)

	
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
				update_quests("Collect", data["original_item_id"], stack)
				quest_log.load_panels()
				return
	
	for inventory_slot in PlayerData.inv_data:
		if PlayerData.inv_data[inventory_slot]["Item"] == null:
			target_inv_slot = inventory_slot
			break

	if target_inv_slot != null:
		PlayerData.inv_data[target_inv_slot]["Item"] = data["original_item_id"]
		update_quests("Collect", data["original_item_id"], stack)
		quest_log.load_panels()
		var inv_node = get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer/" + target_inv_slot + "/Icon")
		var inv_stack_node = get_node("/root/MainScene/CanvasLayer/Inventory/Background/M/V/ScrollContainer/GridContainer/" + target_inv_slot + "/Stack")
		inv_node.texture = data["original_texture"]
		inv_node.get_node("Sweep").texture_progress = load("res://UI_elements/UI_Square.png")#data["original_texture"]
		inv_node.get_node("Sweep/Timer").wait_time = 20
		PlayerData.inv_data[target_inv_slot]["Stack"] = data["original_stack"]
		PlayerData.inv_data[target_inv_slot]["Info"] = data["original_info"]
		if data["original_info"] != null:
			for stat in ImportData.item_data[item_id]:
				if stat in data["original_info"]:
					if data["original_info"][stat] < 1:
						data["original_stats"][stat] = snapped(data["original_info"][stat], 0.01)
					else:
						data["original_stats"][stat] = int(round(data["original_info"][stat]))
			
			if data["original_info"]["magical"]:
				if data["original_info"]["prefix"]:
					var prefix_value = data["original_info"][data["original_info"]["prefix"]]
					if prefix_value < 1:
						prefix_value = snapped(prefix_value, 0.01)
					else:
						prefix_value = int(round(prefix_value))
					if data["original_stats"][ImportData.magical_properties_data[data["original_info"]["prefix"]]["MagicalStatName"]] != null:
						data["original_stats"][ImportData.magical_properties_data[data["original_info"]["prefix"]]["MagicalStatName"]] += prefix_value
					else:
						data["original_stats"][ImportData.magical_properties_data[data["original_info"]["prefix"]]["MagicalStatName"]] = prefix_value
				if data["original_info"]["suffix"]:
					var suffix_value = data["original_info"][data["original_info"]["suffix"]]
					if suffix_value < 1:
						suffix_value = snapped(suffix_value, 0.01)
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
	
func level_up():
	PlayerData.player_stats["Level"] += 1
	PlayerData.LoadStats()
	var overflowXp = curXp - xpToNextLevel
	xpToNextLevel = int(xpToNextLevel*xpToLevelIncreaseRate)
	curXp = int(overflowXp)
	ui.update_level_text(PlayerData.player_stats["Level"])
	ui.update_xp_bar(curXp, xpToNextLevel)
	stat_points += 2
	skill_points += 4
	character_sheet.LoadStats()
	character_sheet.LoadSkills()
	canvas_layer.LoadShortCuts()
	character_sheet.set_personal_data()
	checkAvailableQuests()
	OnHeal(PlayerData.player_stats["MaxHealth"])
	var level_up_texture = get_node("TextureRect")
	level_up_texture.set_scale(Vector2(0, 0))
	level_up_texture.show()
	var tween = create_tween()
	tween.tween_property(level_up_texture, 'scale', Vector2(1, 1), 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(level_up_texture, 'scale', Vector2(0, 0), 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.6).timeout
	get_node("TextureRect").hide()
	
	
	#hur mkt som ska healas, tiden heal sker, om det är mat eller inte

func heal_over_time(heal_amount, time, food):
	var tick_heal = float(heal_amount) / time
	tick_heal = int(tick_heal)
	if food:
		for n in time:
			await get_tree().create_timer(1).timeout
			OnHeal(tick_heal)
		eating = false
	else:
		for n in time:
			await get_tree().create_timer(1).timeout
			OnHeal(tick_heal)

func OnHeal(heal_amount):
	if health  + heal_amount >= PlayerData.player_stats["MaxHealth"]:
		health = PlayerData.player_stats["MaxHealth"]
	else:
		health += heal_amount
	var text = floating_text.instantiate()
	text.amount = heal_amount
	text.type = "Heal"
	text.set_position(position)
	get_tree().get_root().add_child(text)
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
	
func take_damage_over_time(damage_amount, time, type):
	var tick_damage = float(damage_amount) / time
	tick_damage = int(tick_damage)
	if type == "Fire":
		var fire_node = get_node("Fire")
		fire_node.restart()
		fire_node.visible = true
	for n in time:
		await get_tree().create_timer(1).timeout
		take_damage(tick_damage, 0, 0, true)
		if died:
			break
	if type == "Fire":
		get_node("Fire").visible = false
	died = false
	
func mana_boost(mana_amount):
	if mana  + mana_amount >= PlayerData.player_stats["MaxMana"]:
		mana = PlayerData.player_stats["MaxMana"]
	else:
		mana += mana_amount
	var text = floating_text.instantiate()
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
			await get_tree().create_timer(1).timeout
			mana_boost(tick_mana)
		drinking = false
	else:
		for n in time:
			await get_tree().create_timer(1).timeout
			OnHeal(tick_mana)
	
func take_damage(attack, critChance, critFactor, in_range):
	var dmgToTake = attack*(float(50)/(50 + PlayerData.player_stats["Defense"]))
	var type
	var text = floating_text.instantiate()
	randomize()
	if !in_range:
		type = "Miss"
		dmgToTake = 0
	elif randf() <=  PlayerData.player_stats["BlockChance"]:
		type = "Block"
		dmgToTake *= 0.5
		var second_text = floating_text.instantiate()
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
		
func die():
	died = true
	if facingDir.x == 1:
		play_animation("die_right")
	else:
		play_animation("die_left")
	await get_tree().create_timer(2).timeout
	end_scene.show()
	get_tree().paused = true
	
func reset_player():
	if targeted != null:
		targeted.get_node("Sprite2D").material.set_shader_parameter("outline_width", 1)
		targeted.get_node("Sprite2D").material.set_shader_parameter("outline_color", Color('353540'))
	health = 20
	ui.update_health_bar(health, PlayerData.player_stats["MaxHealth"])
	health_bar._on_health_updated(health, PlayerData.player_stats["MaxHealth"])
	self.global_position = Vector2(3830, 3062)
	enemy_ui.hide()
	auto_attacking = false
	targeted = null
	var anim_player = get_node("PlayerAnimationPlayer")
	anim_player.play_backwards("die_right")

	
func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		try_interact()
	if Input.is_action_just_pressed("tab_target"):
		tab_target()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				var walkingMarkerInstance = walkingMarker.instantiate()
				walkingMarkerInstance.position = get_global_mouse_position()
				get_parent().add_child(walkingMarkerInstance)
				auto_attacking = false
				last_clicked_pos = get_global_mouse_position()
	
	if event.is_action_pressed("ui_cancel"):
		if targeted != null:
			targeted.get_node("Sprite2D").material.set_shader_parameter("outline_width", 1)
			targeted.get_node("Sprite2D").material.set_shader_parameter("outline_color", Color('353540'))
			targeted = null
			#enemy_ui.hide()
			auto_attacking = false


func _input(event):
	if event is InputEventMouseButton and event.pressed and hasSkillCursor:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				SkillLoop(selected_skill_texture_button_node)
				canvas_layer.get_node("MouseCursorSkill").reset_cursor()
				get_node("SkillRangeNode").hide()
				await get_tree().create_timer(0.2).timeout
				hasSkillCursor = false

	if event is InputEventKey:
		if [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9].has(event.keycode) and event.is_pressed():
			var number = event.keycode -48
			if number < 8:
				canvas_layer.SelectShortcut("ShortCut" + str(number))
		

func try_interact ():
	#rayCast.target_position = facingDir * interactDist
	#rayCast.force_raycast_update()
	#if rayCast.is_colliding():
	#	if rayCast.get_collider().has_method("on_interact"):
	#		rayCast.get_collider().on_interact(self)
	print(str(interactables))
	if interactables.is_empty():
		return
	else:
		var closest_interactable
		for interactable in interactables:
			if closest_interactable == null:
				closest_interactable = interactable
			else:
				if position.distance_to(interactable.position) < position.distance_to(closest_interactable.position):
					closest_interactable = interactable
		if closest_interactable != null:
			closest_interactable.on_interact(self)
			
func target_enemy (enemy):
	
	if targeted == enemy:
		enemy.get_node("Sprite2D").material.set_shader_parameter("outline_width", 1)
		enemy.get_node("Sprite2D").material.set_shader_parameter("outline_color", Color('353540'))
		targeted = null
		enemy_ui.hide()
	else:
		if targeted != null:
			targeted.get_node("Sprite2D").material.set_shader_parameter("outline_width", 1)
			targeted.get_node("Sprite2D").material.set_shader_parameter("outline_color", Color('353540'))
		targeted = enemy
		enemy.get_node("Sprite2D").material.set_shader_parameter("outline_width", 2)
		enemy.get_node("Sprite2D").material.set_shader_parameter("outline_color", Color('f00d0d'))
		enemy_ui.load_ui(enemy)

func auto_attack():
	if autoAttacking == false:
		#autoAttacking = true
		main_hand_glow.visible = true
		if targeted == null or position.distance_to(targeted.position) > attackDist:
			main_hand_glow.visible = false
			autoAttacking = false
		else:
			if position.distance_to(targeted.position) <= attackDist and targeted != null and auto_timer_ready:
				#auto_timer_ready = false
				animate_attack()
				#var attack_speed = 1.0/(PlayerData.player_stats["AttackSpeed"])
				#cast_bar.use_castbar("Auto attack", attack_speed)
				#await get_tree().create_timer(attack_speed).timeout
				#auto_timer_ready = true
				#main_hand_glow.visible = false
				#autoAttacking = false
				#auto_attack()

func deal_damage_from_auto():
	auto_timer_ready = false
	if targeted != null:
		var in_range = position.distance_to(targeted.position) < attackDist
		if ranged_auto:
			send_projectile()
			if line_of_sight():
				targeted.take_damage(PlayerData.player_stats["PhysicalAttack"], PlayerData.player_stats["CriticalChance"], PlayerData.player_stats["CriticalFactor"], in_range)
		else:
			targeted.take_damage(PlayerData.player_stats["PhysicalAttack"], PlayerData.player_stats["CriticalChance"], PlayerData.player_stats["CriticalFactor"], in_range)
			#0.3 is the time already spent in animation
	var attack_speed = 1.0/(PlayerData.player_stats["AttackSpeed"])
	if attack_speed < 0.1:
		attack_speed = 0.1
		
	var texture_button_node = get_node("/root/MainScene/CanvasLayer/SkillBar/Background/HBoxContainer/ShortCut1/TextureButton")
	texture_button_node.get_node("Sweep").texture_progress = load("res://UI_elements/UI_Square.png")
	texture_button_node.get_node("Sweep/Timer").wait_time = attack_speed + 0.3
	texture_button_node.start_cooldown()
	
	#var loaded_skills = canvas_layer.loaded_skills
	#for shortcut in loaded_skills.keys():
	#	if loaded_skills[shortcut]["Name"] == '1007':
	#		var texture_button_node = canvas_layer.get_node("SkillBar/Background/HBoxContainer/" + shortcut)
	#		texture_button_node.get_node("Sweep").texture_progress = load("res://UI_elements/UI_Square.png")
	#		texture_button_node.get_node("Sweep/Timer").wait_time = attack_speed + 0.3
	#		texture_button_node.start_cooldown()
	#cast_bar.use_castbar("Auto attack", attack_speed + 0.3)
	await get_tree().create_timer(attack_speed).timeout
	auto_timer_ready = true
	main_hand_glow.visible = false
	autoAttacking = false
	auto_attack()

func send_projectile():
	get_node("TurnAxis").rotation = get_angle_to(targeted.get_global_position())
	var auto_projectile = load("res://RangedSingleTargetTargetedSkill.tscn")
	var projectile_instance = auto_projectile.instantiate()
	#projectile_instance.get_node("PointLight2D").color = Color("6ae7f0")
	projectile_instance.skill_name = "10016"
	projectile_instance.caster = self
	projectile_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
	projectile_instance.rotation = get_angle_to(targeted.get_global_position())
	#Location to add
	get_parent().add_child(projectile_instance)

func line_of_sight():
	var raycast = get_node("AutoRaycast")
	raycast.target_position = targeted.position - position
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if str(raycast.get_collider()) == "sten":
			return false
		else:
			return true
	else:
		return true

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
	#var length = tabbed_enemies.size()
	if current_enemy != null:
		tabbed_enemies.append(current_enemy)
	elif at_least_one_in_range:
		tabbed_enemies = []
		tab_target()

func animate_attack():
	var animationSpeed = PlayerData.player_stats["AttackSpeed"] + 1
	print("animationSpeed: " + str(animationSpeed))
	#anim_arms.playback_speed = attackSpeed
	#if autoAttacking:
	if facingDir.x == 1:
		if ranged_auto:
			anim.play("shoot_right", -1, animationSpeed)
		else:
			anim.play("hit_right", -1, animationSpeed)
	elif facingDir.x == -1:
		if ranged_auto:
			anim.play("shoot_left", -1, animationSpeed)
		else:
			anim.play("hit_left", -1, animationSpeed)


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
	if equipment_slot == "MainHand":
		set_auto_attack_range(item_id)
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
	remove_quest_marks()
	var available_quests = getAvailableQuests()
	for quest in available_quests:
		activateQuest(quest, "Exclaim")

	var finished_quests = npc_quest_window.get_finished_npc_quests()
	for quest in finished_quests:
		activateQuest(quest, "Question")

func getAvailableQuests():
	var current_level = PlayerData.player_stats["Level"]
	var available_quests = []
	for i in ImportData.quest_data.keys():
		var npc_name = ImportData.quest_data[i]["Npc"]
		if npc_name != null:
			var required_level = ImportData.quest_data[i]["AvailableRequirements"]["PlayerLevel"]
			var required_completed_quests = ImportData.quest_data[i]["AvailableRequirements"]["CompletedQuests"]
			if required_level <= current_level:
				var completed_required_quests = checkRequiredQuests(required_completed_quests) 
				if completed_required_quests:
					var quest_id = i
					var player_quest_data = PlayerData.quest_data[str(i)]
					var quest_accepted = player_quest_data["Accepted"]
					var quest_abandoned = player_quest_data["Abandoned"]
					var quest_completed = player_quest_data["Completed"]
					if(!quest_accepted and !quest_abandoned and !quest_completed):
						available_quests.append(quest_id)
	return available_quests

func activateQuest(quest_id, type):
	var npc_name = ""
	var mark_texture
	if type == "Exclaim":
		npc_name = ImportData.quest_data[quest_id]["Npc"]
		mark_texture = load("res://Sprites/exlaimationmark.png")
	if type == "Question":
		npc_name = ImportData.quest_data[quest_id]["ReturnNpc"]
		mark_texture = load("res://Sprites/questionmark.png")
	if npc_name == "" or mark_texture == null:
		return
	var main_scene = get_parent()
	for i in main_scene.get_child_count():
		var child = main_scene.get_child(i)
		if "user_name" in child:
			if child.user_name == npc_name:
				var exclamation_mark = child.get_node("ExclamationMark")
				if type == "Exclaim" and exclamation_mark.visible:
					return
				exclamation_mark.show()
				var texture = exclamation_mark.get_node("TextureRect")
				texture.set_texture(mark_texture)

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

func remove_quest_marks():
	var unique_npc_names = get_all_quest_npc_names()
	var main_scene = get_parent()
	for i in main_scene.get_child_count():
		var child = main_scene.get_child(i)
		if "user_name" in child:
			if unique_npc_names.has(child.user_name):
				var exclamation_mark = child.get_node("ExclamationMark")
				exclamation_mark.hide()

func get_all_quest_npc_names():
	var unique_npc_names = []
	for i in ImportData.quest_data.keys():
		var npc_name = ImportData.quest_data[i]["Npc"]
		if !unique_npc_names.has(npc_name):
			unique_npc_names.append(npc_name)
	return unique_npc_names

func get_active_quests():
	var active_quests = []
	for i in PlayerData.quest_data.keys():
		var quest_completed = PlayerData.quest_data[i]["Completed"]
		var quest_abandoned = PlayerData.quest_data[i]["Abandoned"]
		var quest_accepted = PlayerData.quest_data[i]["Accepted"]
		if quest_accepted and !quest_completed and !quest_abandoned:
			active_quests.append(i)
	return active_quests

func update_quests(type, variant, amount):
	if type == "Collect":
		variant = ImportData.item_data[variant]["Name"]
	if variant in PlayerData.quest_requirements_tracking[type].keys():
		var relevant_quests = PlayerData.quest_requirements_tracking[type][variant]
		if type == "Kill" or type == "Collect":
			for i in relevant_quests.keys():
				if relevant_quests[i] == null:
					return
				if amount > 1:
					relevant_quests[i] = relevant_quests[i] + amount
				else:
					relevant_quests[i] = relevant_quests[i] + 1
		if type == "Talk":
			for i in relevant_quests.keys():
				if relevant_quests[i] == null:
					return
				relevant_quests[i] = true

func item_count_in_inventory(type, id):
	var item_id = null
	if type == "Name":
		for i in ImportData.item_data.keys():
			if ImportData.item_data[i]["Name"] == id:
				item_id = i
				break
	if type == "Id":
		item_id = id

	if item_id == null:
		return 0

	var amount = 0
	for i in PlayerData.inv_data.keys():
		if PlayerData.inv_data[i]["Item"] == item_id:
			if PlayerData.inv_data[i]["Stack"] == null:
				amount = amount + 1
			if PlayerData.inv_data[i]["Stack"] == 0:
				amount = amount + 1
			if PlayerData.inv_data[i]["Stack"] > 0:
				amount = amount + PlayerData.inv_data[i]["Stack"]
			break
	return amount

func set_auto_attack_range(item_id):
	if item_id and ImportData.item_data[item_id]["Type"] == "Bow":
		attackDist = 150
		ranged_auto = true
	else:
		attackDist = 60
		ranged_auto = false
	

func add_interactable(interactable):
	interactables.append(interactable)
	interact_text.show()

func remove_interactable(interactable):
	var index = interactables.find(interactable, 0)
	if index >= 0:
		interactables.remove_at(index)
	if interactables.is_empty():
		interact_text.hide()

func _on_interact_area_2d_area_entered(area):
	if area.has_method("on_interact"):
		add_interactable(area)


func _on_interact_area_2d_body_entered(body):
	if body.has_method("on_interact"):
		add_interactable(body)


func _on_interact_area_2d_area_exited(area):
	if area.has_method("on_interact"):
		remove_interactable(area)


func _on_interact_area_2d_body_exited(body):
	if body.has_method("on_interact"):
		remove_interactable(body)
