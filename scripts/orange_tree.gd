extends StaticBody2D

# Load the log scene we created in Step 1
var log_scene = preload("res://scenes/log.tscn")

var max_logs = 5
var current_logs = 0

func chop_hit():
	if current_logs < max_logs:
		current_logs += 1
		spawn_log()
	else:
		print("Tree is empty!")

func spawn_log():
	# Create the log
	var new_log = log_scene.instantiate()
	
	# Set position (start at tree center, maybe offset slightly down)
	new_log.global_position = global_position + Vector2(0, 40)
	
	# Add it to the world (not the tree, or it will vanish when tree vanishes)
	get_parent().add_child(new_log)
