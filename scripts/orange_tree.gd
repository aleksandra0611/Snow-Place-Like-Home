extends StaticBody2D

var log_scene = preload("res://scenes/log.tscn")

var max_logs = 5
var current_logs = 0
var respawn_time_duration = 60.0 # 1 minute in seconds

@onready var sprite = $Sprite2D
@onready var collision = $CollisionPolygon2D # Or CollisionShape2D, check your node name!

func _ready():
	# Check if this specific tree (by Name) has a saved respawn time
	if Global.tree_respawn_times.has(name):
		var target_time = Global.tree_respawn_times[name]
		var current_time = Time.get_unix_time_from_system()
		
		if current_time >= target_time:
			# Time has passed! Respawn immediately.
			respawn_tree()
		else:
			# Still waiting. Calculate how much time is left.
			var time_left = target_time - current_time
			hide_tree()
			
			# Start a local timer to finish the countdown while we are in the scene
			get_tree().create_timer(time_left).timeout.connect(respawn_tree)
	else:
		# No saved data means tree is alive
		reset_tree_state()

func chop_hit():
	if current_logs < max_logs:
		current_logs += 1
		spawn_log()
		
		# Visual feedback (shake)
		var tween = create_tween()
		tween.tween_property(sprite, "position", Vector2(5, 0), 0.05)
		tween.tween_property(sprite, "position", Vector2(-5, 0), 0.05)
		tween.tween_property(sprite, "position", Vector2(0, 0), 0.05)
		
		if current_logs >= max_logs:
			kill_tree()
	else:
		print("Tree is empty!")

func spawn_log():
	var new_log = log_scene.instantiate()
	new_log.global_position = global_position + Vector2(0, 40)
	get_parent().add_child(new_log)

func kill_tree():
	print("Tree chopped down!")
	
	# 1. Calculate when it should come back (Current Time + 60 seconds)
	var respawn_timestamp = Time.get_unix_time_from_system() + respawn_time_duration
	
	# 2. Save this to Global memory using the Tree's Name as the ID
	Global.tree_respawn_times[name] = respawn_timestamp
	
	# 3. Hide the tree locally
	hide_tree()
	
	# 4. Start a timer locally (in case player stays in the scene watching)
	get_tree().create_timer(respawn_time_duration).timeout.connect(respawn_tree)

func hide_tree():
	# Make invisible and disable collision
	visible = false
	collision.set_deferred("disabled", true)

func respawn_tree():
	print("Tree respawned!")
	reset_tree_state()
	
	# Remove from global memory since it's alive again
	if Global.tree_respawn_times.has(name):
		Global.tree_respawn_times.erase(name)

func reset_tree_state():
	current_logs = 0
	visible = true
	collision.set_deferred("disabled", false)
