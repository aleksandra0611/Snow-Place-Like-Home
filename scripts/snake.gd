extends CharacterBody2D

# --- STATS ---
var speed = 85
var dead = false
var hp = 1 
# -------------

var player_in_area = false
var attack_range = false
var attacking = false
var soul_scene = preload("res://scenes/soul.tscn")

# Reference to the player
var player: CharacterBody2D = null

# NODES
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $Health

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	# Optional: Hide the bar if health is full, show it only when hit?
	# For now, we leave it visible.

func _physics_process(_delta):
	if dead:
		return 

	# If attacking, stop moving.
	if attacking:
		return

	# CHASE LOGIC
	if player_in_area and player:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
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
		print("Bite! Snake hit the player.")
		player.take_damage(1)
	
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

func _on_detection_area_body_exited(body):
	if body is Player:
		player_in_area = false
		player = null

func _on_attack_area_body_entered(body):
	if body is Player:
		attack_range = true

func _on_attack_area_body_exited(body):
	if body is Player:
		attack_range = false
