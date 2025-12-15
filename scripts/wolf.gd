extends CharacterBody2D

# --- STATS ---
@export var normal_speed = 65.0
@export var night_speed = 85.0
@onready var growl_sfx = $GrowlSFX
var current_speed = normal_speed
var dead = false
var hp = 3 
# -------------

var player_in_area = false
var attack_range = false
var attacking = false
var soul_scene = preload("res://scenes/soul.tscn")

# Reference to the player
var player: CharacterBody2D = null

# NODES
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $Health # Make sure your ProgressBar is named "Health"

func _ready():
	# Initialize bar value
	health_bar.max_value = hp
	health_bar.value = hp
	
	if Global.is_night:
		current_speed = night_speed
	else:
		current_speed = normal_speed
	
	Global.night_started.connect(_on_night_started)
	Global.day_started.connect(_on_day_started)

func _physics_process(_delta):
	if dead:
		return 

	# If attacking, stop moving.
	if attacking:
		return

	# CHASE LOGIC
	if player_in_area and player:
		var direction = (player.position - position).normalized()
		velocity = direction * current_speed
		move_and_slide()
		
		# Animation Handling
		sprite.flip_h = false 
		if direction.x < 0:
			sprite.play("running_left")
		else:
			sprite.play("running_right")
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")

	# ATTACK LOGIC
	if attack_range and not attacking:
		start_attack()

func start_attack():
	attacking = true
	velocity = Vector2.ZERO
	
	# Face player
	if player:
		if player.position.x < position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
	# Attack Sequence
	sprite.play("attack")
	await sprite.animation_finished
	
	# Deal Damage
	if player and attack_range:
		print("Bite! Wolf hit the player.")
		player.take_damage(2)
	
	# Cooldown
	sprite.play("idle")
	await get_tree().create_timer(1.0).timeout
	
	attacking = false

func take_damage(amount):
	hp -= amount
	
	# Update Health Bar
	health_bar.value = hp
	
	# Visual Flash (White)
	sprite.modulate = Color(10, 10, 10) 
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)
	
	if hp <= 0:
		die()

func die():
	dead = true
	velocity = Vector2.ZERO
	health_bar.visible = false
	
	# 2. SILENCE THE WOLF ON DEATH
	if growl_sfx.playing:
		growl_sfx.stop()
	
	sprite.play("killed")
	await sprite.animation_finished
	await get_tree().create_timer(1.0).timeout
	
	var soul = soul_scene.instantiate()
	soul.global_position = global_position
	get_parent().call_deferred("add_child", soul)
	
	queue_free()

# --- SIGNALS ---
func _on_detection_area_body_entered(body):
	if body is Player:
		player_in_area = true
		player = body
		
		# 3. PLAY SOUND (Only if not already playing)
		if not dead and not growl_sfx.playing:
			growl_sfx.play()

func _on_detection_area_body_exited(body):
	if body is Player:
		player_in_area = false
		player = null
		
		# 4. STOP SOUND
		growl_sfx.stop()

func _on_attack_area_body_entered(body):
	if body is Player:
		attack_range = true

func _on_attack_area_body_exited(body):
	if body is Player:
		attack_range = false

func _on_night_started():
	current_speed = night_speed

func _on_day_started():
	current_speed = normal_speed
