extends CharacterBody2D

@export var speed := 100 
@export var stop_distance := 24.0 
@export var start_distance := 35.0 
@export var player_path : NodePath
@export var sleep_delay := 60.0 

# New Combat Variables
@export var attack_range := 25.0 
var damage_timer := 0.0
var current_enemy = null

enum {
	FOLLOW,
	IDLE,
	LAYING_DOWN,
	SLEEPING,
	GETTING_UP,
	ATTACK # New State
}

var state = FOLLOW
var player : CharacterBody2D
var idle_timer := 0.0

@onready var anim = $AnimatedSprite2D

func _ready():
	if not player_path.is_empty():
		player = get_node(player_path)
	
	if not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	# 1. PRIORITY: Check on our enemy
	# If we have a target, but it died or disappeared, stop attacking.
	if current_enemy:
		# Check if enemy is valid (exists) and not marked 'dead'
		if not is_instance_valid(current_enemy) or (current_enemy.get("dead") == true):
			current_enemy = null
			change_state(FOLLOW) # Enemy defeated! Return to owner.
	
	# 2. STATE MACHINE
	match state:
		ATTACK:
			handle_attack_state(delta)
			
		FOLLOW:
			if not player: return
			var vector_to_player = player.global_position - global_position
			var distance = vector_to_player.length()
			
			play_anim("run", vector_to_player)
			velocity = vector_to_player.normalized() * speed
			move_and_slide()
			
			if distance <= stop_distance:
				change_state(IDLE)

		IDLE:
			play_anim("idle")
			velocity = Vector2.ZERO
			move_and_slide()
			
			# If player moves away, follow again (UNLESS we are fighting)
			if player and (player.global_position - global_position).length() > start_distance:
				change_state(FOLLOW)
				return
				
			# Sleep Logic
			if player.velocity.length() < 5.0:
				idle_timer += delta
			else:
				idle_timer = 0.0 
				
			if idle_timer >= sleep_delay:
				change_state(LAYING_DOWN)

		LAYING_DOWN:
			velocity = Vector2.ZERO
			move_and_slide()
			# Logic handled in animation finished

		SLEEPING:
			velocity = Vector2.ZERO
			move_and_slide()
			play_anim("sleep")
			# Wake up if player moves
			if player and player.velocity.length() > 5.0:
				change_state(GETTING_UP)

		GETTING_UP:
			velocity = Vector2.ZERO
			move_and_slide()

# --- COMBAT LOGIC ---
func handle_attack_state(delta):
	if not current_enemy: 
		change_state(FOLLOW)
		return

	var vector_to_enemy = current_enemy.global_position - global_position
	var distance = vector_to_enemy.length()
	
	# Face the enemy
	if vector_to_enemy.x != 0:
		anim.flip_h = vector_to_enemy.x < 0

	if distance > attack_range:
		# CHASE: Enemy is too far, run to them
		play_anim("run") # Or "run_aggressive" if you have it
		velocity = vector_to_enemy.normalized() * speed
		move_and_slide()
	else:
		# FIGHT: Enemy is close, bite them!
		velocity = Vector2.ZERO
		play_anim("attack")
		
		# Damage Timer
		damage_timer += delta
		if damage_timer >= 2.0:
			damage_timer = 0.0
			# Deal damage (using the wolf/enemy standard function)
			if current_enemy.has_method("take_damage"):
				current_enemy.take_damage(1)
				print("Dog bit enemy!")

# --- HELPER: Change State ---
func change_state(new_state):
	if state == new_state: return
	state = new_state
	
	# Reset timers on state change
	idle_timer = 0.0
	damage_timer = 2.0 # Start ready to bite immediately when reaching target
	
	match state:
		LAYING_DOWN: play_anim("lay_down")
		GETTING_UP: play_anim("get_up")
		SLEEPING: play_anim("sleep")

# --- HELPER: Animation ---
func play_anim(anim_name, dir = Vector2.ZERO):
	if dir.x != 0:
		anim.flip_h = dir.x < 0
	if anim.animation != anim_name:
		anim.play(anim_name)

func _on_animation_finished():
	if state == LAYING_DOWN and anim.animation == "lay_down":
		change_state(SLEEPING)
	elif state == GETTING_UP and anim.animation == "get_up":
		change_state(FOLLOW)

# --- SIGNALS ---

# Connect this to your EnemyDetector Area2D!
func _on_enemy_detector_body_entered(body):
	# Check if body has 'take_damage' (is an enemy) AND is not already dead
	if body.has_method("take_damage") and body != self:
		# Don't switch target if we are already fighting someone else
		if state != ATTACK:
			print("Dog detected enemy: ", body.name)
			current_enemy = body
			change_state(ATTACK)
