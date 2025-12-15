extends RigidBody2D

var nearby_player = null 

func _on_pickup_area_body_entered(body):
	# Check if the body is the Player class
	if body is Player:
		nearby_player = body
		# HIGHLIGHT: Make it glow bright blue/white
		$Sprite2D.modulate = Color(1.5, 1.5, 2.5)

func _on_pickup_area_body_exited(body):
	if body is Player:
		nearby_player = null
		# REMOVE HIGHLIGHT: Return to normal
		$Sprite2D.modulate = Color(1, 1, 1)

func _input(event):
	# Check if player is near AND pressed 'E' (interact)
	if nearby_player and Input.is_action_just_pressed("interact"):
		collect_soul()

func collect_soul():
	# Send "soul" to the player's inventory logic
	# Ensure your player script has 'add_to_inventory' function
	nearby_player.add_to_inventory("soul")
	nearby_player.play_pickup_sound()
	# Remove the soul object from the world
	queue_free()
