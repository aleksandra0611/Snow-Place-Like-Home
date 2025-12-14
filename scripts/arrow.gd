extends Area2D

var speed = 400
var direction = Vector2.RIGHT
var damage = 1

func _physics_process(delta):
	# Move in the direction we are facing
	position += direction * speed * delta

func _on_body_entered(body):
	# Don't hit the player!
	if body.name == "MainCharacter":
		return
		
	# If we hit an enemy (we will add this later)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Delete arrow on impact (so it sticks in the wall or disappears)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	# Clean up arrows that fly off screen so game doesn't lag
	queue_free()
