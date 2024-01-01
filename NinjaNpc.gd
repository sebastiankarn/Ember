extends CharacterBody2D

@onready var loot_box = preload("res://Chest.tscn")

var floating_text = preload("res://FloatingText.tscn")
@onready var navAgent = $EnemyNavAgent
var user_name = "Ninja"
var curHp : int = 20
var maxHp : int = 20
var moveSpeed : int = 50
var facingDir = Vector2()
var vel = Vector2()
var xpToGive : int = 30
var attack : int = 40
var critChance : float = 0.1
var critFactor : float = 1.5
var blockChance : float = 0.05
var dodgeChance : float = 0.1
var defense: int = 50
var attackRate : float = 1.0
var changeDir = false
var attackDist : int = 40
var chaseDist : int = 300
@onready var timer = $Timer
@onready var target = get_node("/root/MainScene/Player")
@onready var health_bar = $HealthBar
var step : int = 0
var i : int =  0
var _update_every : int = 500
var canHeal = true

@export var path_to_target := NodePath()
@onready var _agent: NavigationAgent2D = $EnemyNavAgent
@onready var _path_timer: Timer = $PathTimer

var _path : Array = []
var direction: Vector2 = Vector2.ZERO

var mana = 100
var maxMana = 100

var blood = load("res://BloodParticles.tscn")
@onready var npc_inventory_window = get_node("/root/MainScene/CanvasLayer/NpcInventory")


# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar._on_health_updated(curHp, maxHp)
	health_bar._on_mana_updated(mana, maxMana)

func _process(_delta):
	var dist = position.distance_to(target.position)
	if dist < 85:
		get_node("LightOccluder2D").hide()
	else:
		get_node("LightOccluder2D").show()

func on_interact (player):
	open_window(player)

func _on_Timer_timeout():
	if !is_instance_valid(target):
		return
	if position.distance_to(target.position) <= attackDist:
		target.take_damage(attack, critChance, critFactor, true)

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

func _on_Enemy_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		target.last_clicked_pos = target.position
		open_window(target)

func open_window(player):
	#var player_inventory = PlayerData.inv_data
	#npc_inventory_window.load_shop(user_name)
	#npc_inventory_window.load_inventory(player_inventory)
	#npc_inventory_window.visible = !npc_inventory_window.visible
	#hide_tooltips(npc_inventory_window)
	npc_inventory_window.talk_to_npc(self)
