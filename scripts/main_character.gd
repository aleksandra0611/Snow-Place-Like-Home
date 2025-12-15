extends CharacterBody2D
class_name Player
@onready var footstep_sfx = $FootstepSFX
@onready var shoot_sfx = $ShootSFX
@onready var pickup_sfx = $PickupSFX
const SPEED = 100.0

# --- HEALTH VARIABLES ---
var max_health = 10
var health = 10
var dead = false 
# ------------------------

var player_state = "idle" 

var arrow_scene = preload("res://scenes/arrow.tscn")
var can_shoot = true 
var is_holding_shoot = false 

@onready var inventory_ui = $InventoryUI
@onready var health_bar = $HealthBar 
@onready var arrow_label = $ArrowLabel # Make sure you created this!

func _ready():
	# 1. SETUP HEALTH
	health = Global.player_health 
	health_bar.max_value = max_health
	health_bar.value = health
	
	# 2. SETUP ARROWS (Update the visual label)
	update_arrow_label()
	
	# 3. POSITION LOGIC
	if Global.next_player_position != null:
		global_position = Global.next_player_position
		Global.next_player_position = null

	# 4. INVENTORY LOGIC
	if Global.saved_inventory.size() > 0:
		inventory_ui.load_items_from_global(Global.saved_inventory)

func _physics_process(_delta):
	if dead: return
	if player_state == "chop":
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if player_state != "attack":
		if direction == Vector2.ZERO:
			player_state = "idle"
			footstep_sfx.stop()
		else:
			player_state = "run"
			
			if velocity.length() > 0 and not footstep_sfx.playing:
				footstep_sfx.play()
	
	velocity = direction * SPEED
	move_and_slide()
	
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_ui.visible = !inventory_ui.visible
	if Input.is_action_just_pressed("chop"):
		start_chop()
	
	# CHECK IF WE HAVE ARROWS BEFORE SHOOTING
	if Input.is_action_pressed("shoot") and can_shoot and Global.player_arrows > 0:
		handle_shooting()
	
	if Input.is_action_just_released("shoot"):
		is_holding_shoot = false
	
	play_anim(direction)

# --- NEW HELPER FOR UI ---
func update_arrow_label():
	arrow_label.text = "Arrows: " + str(Global.player_arrows)

# --- DAMAGE & DEATH ---
func take_damage(amount):
	if dead: return
	health -= amount
	health_bar.value = health
	$AnimatedSprite2D.modulate = Color(3, 0, 0)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)
	if health <= 0: die()

func die():
	dead = true
	velocity = Vector2.ZERO
	player_state = "dead"
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished
	await get_tree().create_timer(1.0).timeout
	Global.player_health = max_health 
	get_tree().reload_current_scene()
	
func _exit_tree():
	Global.saved_inventory = inventory_ui.save_items_to_global()
	Global.player_health = health

# --- HEALING ---
func heal(amount):
	if dead or health >= max_health: return false 
	health += amount
	if health > max_health: health = max_health
	health_bar.value = health
	visual_heal_effect()
	return true 

func visual_heal_effect():
	$AnimatedSprite2D.modulate = Color(0, 3, 0) 
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)

# --- SHOOTING ---
func handle_shooting():
	player_state = "attack"
	can_shoot = false 
	var mouse_pos = get_global_mouse_position()
	var aim_direction = (mouse_pos - global_position).normalized()
	
	# Visuals (Flipping sprite)
	if mouse_pos.x < global_position.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

	# Animation Logic
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.play("run")
		is_holding_shoot = true 
	else:
		if Input.is_action_just_pressed("shoot"):
			$AnimatedSprite2D.play("normalAttack")
			is_holding_shoot = true
		elif is_holding_shoot:
			$AnimatedSprite2D.play("loopAttack")
	
	# --- SOUND FIX HERE ---
	# We play the sound OUTSIDE the if/else blocks above.
	# If we are in this function, we are about to shoot, so play the sound!
	if shoot_sfx:
		shoot_sfx.pitch_scale = randf_range(0.9, 1.1) # Optional variety
		shoot_sfx.play()

	# Fire the actual arrow
	fire_arrow(aim_direction)
	
	# Subtract ammo
	Global.player_arrows -= 1
	update_arrow_label() 
	
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

# --- OTHERS ---
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

# --- SHOP HELPERS ---
func get_item_count(item_name):
	var count = 0
	var grid = inventory_ui.get_node("Panel/GridContainer")
	for slot in grid.get_children():
		for child in slot.get_children():
			if child is TextureRect and child.texture.resource_path.ends_with(item_name + ".png"):
				var label = slot.get_node("AmountLabel")
				if label.visible: count += int(label.text)
				else: count += 1
	return count

func remove_items(item_name, amount_to_remove):
	var grid = inventory_ui.get_node("Panel/GridContainer")
	var remaining = amount_to_remove
	for slot in grid.get_children():
		if remaining <= 0: break
		var icon = null
		for child in slot.get_children():
			if child is TextureRect and child.texture.resource_path.ends_with(item_name + ".png"):
				icon = child
				break
		if icon:
			var label = slot.get_node("AmountLabel")
			var current_stack = 1
			if label.visible: current_stack = int(label.text)
			if current_stack > remaining:
				current_stack -= remaining
				label.text = str(current_stack)
				remaining = 0
			else:
				remaining -= current_stack
				icon.queue_free() 
				label.visible = false 
				label.text = "1"

func play_pickup_sound():
	# We don't need arguments anymore!
	
	# Randomize pitch slightly so it doesn't sound robotic
	pickup_sfx.pitch_scale = randf_range(0.9, 1.1)
	
	# Play the sound you dragged into the inspector
	pickup_sfx.play()
