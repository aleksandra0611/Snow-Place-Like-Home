extends CharacterBody2D
class_name Player

const SPEED = 100.0

# --- HEALTH VARIABLES ---
var max_health = 10
var health = 10
var dead = false # New variable to track if we are dead
# ------------------------

# Initialize state
var player_state = "idle" 

var arrow_scene = preload("res://scenes/arrow.tscn")
var can_shoot = true 
var is_holding_shoot = false 

@onready var inventory_ui = $InventoryUI
@onready var health_bar = $HealthBar 

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health

func _physics_process(_delta):
	# 0. DEAD STATE
	# If dead, stop everything. No moving, no shooting.
	if dead:
		return

	# 1. BLOCKING STATE (Chop)
	if player_state == "chop":
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# 2. MOVEMENT
	var direction = Input.get_vector("left", "right", "up", "down")
	if player_state != "attack":
		if direction == Vector2.ZERO:
			player_state = "idle"
		else:
			player_state = "run"
	
	velocity = direction * SPEED
	move_and_slide()
	
	# 3. INPUT
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_ui.visible = !inventory_ui.visible
	if Input.is_action_just_pressed("chop"):
		start_chop()
	if Input.is_action_pressed("shoot") and can_shoot:
		handle_shooting()
	if Input.is_action_just_released("shoot"):
		is_holding_shoot = false
	
	play_anim(direction)

# --- DAMAGE & DEATH SYSTEM ---
func take_damage(amount):
	# Don't take damage if already dead
	if dead:
		return
		
	health -= amount
	health_bar.value = health
	
	# Visual Feedback (Flash Red)
	$AnimatedSprite2D.modulate = Color(3, 0, 0)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)
	
	if health <= 0:
		die()

func die():
	print("Player Died!")
	dead = true
	velocity = Vector2.ZERO
	player_state = "dead"
	
	# 1. Play Death Animation
	# CHANGE "death" TO YOUR ACTUAL ANIMATION NAME IF DIFFERENT
	$AnimatedSprite2D.play("death")
	
	# 2. Wait for animation to finish
	await $AnimatedSprite2D.animation_finished
	
	# 3. Wait a moment for dramatic effect (1 second)
	await get_tree().create_timer(1.0).timeout
	
	# 4. Respawn (Reload Scene)
	get_tree().reload_current_scene()
# -----------------------------

func handle_shooting():
	player_state = "attack"
	can_shoot = false 
	var mouse_pos = get_global_mouse_position()
	var aim_direction = (mouse_pos - global_position).normalized()
	if mouse_pos.x < global_position.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.play("run")
		is_holding_shoot = true 
	else:
		if Input.is_action_just_pressed("shoot"):
			$AnimatedSprite2D.play("normalAttack")
			is_holding_shoot = true
		elif is_holding_shoot:
			$AnimatedSprite2D.play("loopAttack")
	fire_arrow(aim_direction)
	await get_tree().create_timer(0.8).timeout
	can_shoot = true
	if not Input.is_action_pressed("shoot"):
		player_state = "idle"

func fire_arrow(dir):
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position 
	arrow.direction = dir
	arrow.rotation = dir.angle()
	get_parent().add_child(arrow)

func start_chop():
	player_state = "chop"
	$AnimatedSprite2D.play("chop")
	var bodies = $AxeHitbox.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("chop_hit"):
			body.chop_hit()
	if not $AnimatedSprite2D.animation_finished.is_connected(_on_chop_finished):
		$AnimatedSprite2D.animation_finished.connect(_on_chop_finished, CONNECT_ONE_SHOT)

func _on_chop_finished():
	player_state = "idle"

func play_anim(dir):
	# If dead, do NOT play other animations
	if dead: return
	if player_state == "chop": return
	if player_state == "attack": return
	
	if dir.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AxeHitbox.position.x = -20
	elif dir.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AxeHitbox.position.x = 20
	if player_state == "idle":
		$AnimatedSprite2D.play("idle")
	if player_state == "run":
		$AnimatedSprite2D.play("run")

func add_to_inventory(item_name):
	inventory_ui.add_item(item_name)
