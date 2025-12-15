extends RigidBody2D

var nearby_player = null 

func _on_pickup_area_body_entered(body):
	if body is Player:
		nearby_player = body # <--- Save the player so we can talk to him later
		# HIGHLIGHT
		$Sprite2D.modulate = Color(1.5, 1.5, 1.5)

func _on_pickup_area_body_exited(body):
	if body is Player:
		nearby_player = null 
		# REMOVE HIGHLIGHT
		$Sprite2D.modulate = Color(1, 1, 1)

func _input(event):
	if nearby_player and Input.is_action_just_pressed("interact"):
		collect_log()

func collect_log():
	print("Log collected!")
	
	nearby_player.add_to_inventory("log")
	nearby_player.play_pickup_sound()
	queue_free()
