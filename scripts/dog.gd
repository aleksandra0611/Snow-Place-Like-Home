extends CharacterBody2D

@export var speed := 80.0
@export var stop_distance := 24.0 # Distance to stop moving
@export var start_distance := 35.0 # Distance to start moving again (prevents jitter)
@export var player_path : NodePath
@export var sleep_delay := 60.0 # Seconds before sleeping

# Simple State Machine
enum {
	FOLLOW,
	IDLE,
	LAYING_DOWN,
	SLEEPING,
	GETTING_UP
}

var state = FOLLOW
var player : CharacterBody2D
var idle_timer := 0.0

@onready var anim = $AnimatedSprite2D

func _ready():
	if not player_path.is_empty():
		player = get_node(player_path)
	
	# Connect the signal safely
	if not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if not player:
		return

	# Calculate distance and check if player is moving
	var vector_to_player = player.global_position - global_position
	var distance = vector_to_player.length()
	var player_is_moving = player.velocity.length() > 5.0 # Small threshold to be safe

	# --- GLOBAL LOGIC: Check for interruptions ---
	# If player moves while dog is laying down or sleeping, WAKE UP immediately
	if player_is_moving and state in [IDLE, LAYING_DOWN, SLEEPING]:
		if state == SLEEPING or state == LAYING_DOWN:
			change_state(GETTING_UP)
		else:
			change_state(FOLLOW)
			
	# --- STATE LOGIC ---
	match state:
		FOLLOW:
			play_anim("run", vector_to_player)
			# Move towards player
			velocity = vector_to_player.normalized() * speed
			move_and_slide()
			
			# If close enough, switch to IDLE
			if distance <= stop_distance:
				change_state(IDLE)

		IDLE:
			play_anim("idle")
			velocity = Vector2.ZERO
			move_and_slide()
			
			# If player moves away, follow again
			if distance > start_distance:
				change_state(FOLLOW)
				return
				
			# If player is NOT moving, count up the timer
			if not player_is_moving:
				idle_timer += delta
			else:
				idle_timer = 0.0 # Reset if player twitches
				
			# Trigger sleep sequence after 60 seconds
			if idle_timer >= sleep_delay:
				change_state(LAYING_DOWN)

		LAYING_DOWN:
			velocity = Vector2.ZERO
			move_and_slide()
			# Logic is handled in _on_animation_finished

		SLEEPING:
			velocity = Vector2.ZERO
			move_and_slide()
			play_anim("sleep")
			# Logic to wake up is in the "Global Logic" section at the top

		GETTING_UP:
			velocity = Vector2.ZERO
			move_and_slide()
			# Logic is handled in _on_animation_finished

# --- HELPER: Handles State Changes cleanly ---
func change_state(new_state):
	# Don't restart the same state (unless needed)
	if state == new_state:
		return
		
	state = new_state
	
	match state:
		FOLLOW:
			idle_timer = 0.0
		IDLE:
			idle_timer = 0.0
		LAYING_DOWN:
			play_anim("lay_down")
		GETTING_UP:
			play_anim("get_up")
		SLEEPING:
			play_anim("sleep")

# --- HELPER: Animation Player ---
func play_anim(anim_name, dir = Vector2.ZERO):
	# Handle flipping only when moving
	if dir.x != 0:
		anim.flip_h = dir.x < 0
	
	# Only play if not already playing to avoid resetting loop
	if anim.animation != anim_name:
		anim.play(anim_name)

# --- SIGNAL: Animation Finished ---
func _on_animation_finished():
	if state == LAYING_DOWN:
		# Transition: Lay Down -> Sleep
		if anim.animation == "lay_down":
			change_state(SLEEPING)
			
	elif state == GETTING_UP:
		# Transition: Get Up -> Follow (or Idle)
		if anim.animation == "get_up":
			change_state(FOLLOW)
