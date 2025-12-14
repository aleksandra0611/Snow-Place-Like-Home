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
	
	# --- SHOP SYSTEM HELPERS ---

func get_item_count(item_name):
	# Counts how many of a specific item (like "soul") we have in the UI
	var count = 0
	var grid = inventory_ui.get_node("Panel/GridContainer")
	
	for slot in grid.get_children():
		# Find the icon in the slot
		for child in slot.get_children():
			if child is TextureRect and child.texture.resource_path.ends_with(item_name + ".png"):
				# Check the AmountLabel if it exists/is visible
				var label = slot.get_node("AmountLabel")
				if label.visible:
					count += int(label.text)
				else:
					count += 1
	return count

func remove_items(item_name, amount_to_remove):
	# Removes a specific number of items (for paying)
	var grid = inventory_ui.get_node("Panel/GridContainer")
	var remaining = amount_to_remove
	
	for slot in grid.get_children():
		if remaining <= 0: break
		
		# Find the item
		var icon = null
		for child in slot.get_children():
			if child is TextureRect and child.texture.resource_path.ends_with(item_name + ".png"):
				icon = child
				break
		
		if icon:
			var label = slot.get_node("AmountLabel")
			var current_stack = 1
			if label.visible:
				current_stack = int(label.text)
			
			# Logic to reduce stack or delete item
			if current_stack > remaining:
				# Just reduce the number
				current_stack -= remaining
				label.text = str(current_stack)
				remaining = 0
			else:
				# Remove the whole stack and keep going
				remaining -= current_stack
				icon.queue_free() # Remove the image
				label.visible = false # Hide the label
				label.text = "1" # Reset label
