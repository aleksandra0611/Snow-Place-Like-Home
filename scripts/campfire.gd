extends StaticBody2D

# CONFIGURATION
@export var time_added_per_log = 30.0 
var current_fuel_time = 60.0 
var is_burning = true
var player_in_range = false

# NODES
@onready var burning_sprite = $AnimatedSprite2D
@onready var dead_sprite = $DeadFireVisuals 
@onready var interact_area = $InteractArea 
@onready var timer_label = $TimerLabel
@onready var add_fuel_sfx = $AddFuelSFX # <--- New Audio Node

func _ready():
	update_visuals(true)
	
	if not interact_area.body_entered.is_connected(_on_body_entered):
		interact_area.body_entered.connect(_on_body_entered)
	if not interact_area.body_exited.is_connected(_on_body_exited):
		interact_area.body_exited.connect(_on_body_exited)

func _process(delta):
	# --- UPDATE LABEL ---
	if is_burning:
		timer_label.text = str(int(current_fuel_time)) + "s"
		timer_label.visible = true
	else:
		if player_in_range:
			timer_label.text = "Add Log (E)"
			timer_label.visible = true
		else:
			timer_label.visible = false

	# --- BURN LOGIC ---
	if is_burning:
		current_fuel_time -= delta
		if current_fuel_time <= 0:
			put_out_fire()

func _input(event):
	if player_in_range and Input.is_action_just_pressed("interact"):
		attempt_add_fuel()

func attempt_add_fuel():
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		if player.get_item_count("log") >= 1:
			player.remove_items("log", 1)
			
			current_fuel_time += time_added_per_log
			print("Fuel added! Time: ", int(current_fuel_time))
			
			# 1. PLAY SOUND
			add_fuel_sfx.pitch_scale = randf_range(0.9, 1.1)
			add_fuel_sfx.play()
			
			if not is_burning:
				start_fire()
		else:
			print("You need logs!")

func start_fire():
	is_burning = true
	update_visuals(true)

func put_out_fire():
	is_burning = false
	current_fuel_time = 0.0
	update_visuals(false)

func update_visuals(burning_state):
	if burning_state:
		burning_sprite.visible = true
		burning_sprite.play("burning")
		dead_sprite.visible = false
	else:
		burning_sprite.visible = false
		dead_sprite.visible = true

# --- DETECTION & HIGHLIGHT ---
func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		
		# 2. HIGHLIGHT ON (Make it brighter)
		burning_sprite.modulate = Color(1.3, 1.3, 1.3)
		dead_sprite.modulate = Color(1.3, 1.3, 1.3)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		
		# 3. HIGHLIGHT OFF (Reset to normal)
		burning_sprite.modulate = Color(1, 1, 1)
		dead_sprite.modulate = Color(1, 1, 1)
