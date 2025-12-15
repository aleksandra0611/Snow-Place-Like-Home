extends Area2D

var speed = 400
var direction = Vector2.RIGHT
var damage = 1

func _physics_process(delta):
	# Move in the direction we are facing
	position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "MainCharacter":
		return
		
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# 1. VISUALS OFF
	visible = false
	speed = 0
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 2. SOUND ON
	if has_node("HitSFX"):
		$HitSFX.play()
		# Wait for sound, but max 1 second so arrow doesn't get stuck forever in memory
		await get_tree().create_timer(1.0).timeout 
		# (We use a timer instead of .finished just in case the sound is broken)
	
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	# Clean up arrows that fly off screen so game doesn't lag
	queue_free()
