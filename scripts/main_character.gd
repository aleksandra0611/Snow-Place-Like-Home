extends CharacterBody2D


const SPEED = 100.0

var player_state

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.x == 0 and direction.y == 0:
		player_state = "idle"
	elif direction.x != 0 or direction.y != 0:
		player_state = "run"
	
	velocity = direction * SPEED
	move_and_slide()
	
	play_anim(direction)
	

func play_anim(dir):
	if dir.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif dir.x > 0:
		$AnimatedSprite2D.flip_h = false

	if player_state == "idle":
		$AnimatedSprite2D.play("idle")

	if player_state == "run":
		$AnimatedSprite2D.play("run")
