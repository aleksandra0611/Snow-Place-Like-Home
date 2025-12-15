extends Node2D

@onready var day_anim = $AnimationPlayer

# Define when night starts/ends based on your keyframes
var night_start_time = 180.0
var night_end_time = 300.0 # Loops back to 0

func _ready():
	day_anim.play("cycle")
	day_anim.seek(Global.current_day_time)
	day_anim.speed_scale = 10.0
	
	# RESTORE STATE:
	# If we load back in and it was already night, ensure variables match
	if Global.current_day_time >= night_start_time:
		Global.is_night = true
	else:
		Global.is_night = false

func _process(_delta):
	# Save time continuously
	Global.current_day_time = day_anim.current_animation_position
	var time = Global.current_day_time
	
	# CHECK FOR NIGHT START
	# We use a small buffer so it doesn't trigger multiple times
	if time >= night_start_time and not Global.is_night:
		print("Night has fallen. Beasts are faster.")
		Global.is_night = true
		Global.night_started.emit() # Alert everyone!

	# CHECK FOR DAY START (Loop reset)
	# Since animation loops to 0, we check if time is very low (morning)
	if time < 10.0 and Global.is_night:
		print("Sun is rising. Beasts calm down.")
		Global.is_night = false
		Global.day_started.emit() # Alert everyone!
	
