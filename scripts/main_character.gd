extends CharacterBody2D


const SPEED = 100.0

var player_state

func _physics_process(_delta):
	if player_state == "chop":
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.x == 0 and direction.y == 0:
		player_state = "idle"
	elif direction.x != 0 and direction.y == 0:
		player_state = "run"
	elif direction.y != 0 and direction.x ==0:
		player_state = "run"
	elif direction.y != 0 and direction.x != 0:
		player_state = "run"
	velocity = direction * SPEED
	move_and_slide()
	
	if Input.is_action_just_pressed("chop"):
		start_chop()
	
	play_anim(direction)
	

func start_chop():
	player_state = "chop"
	$AnimatedSprite2D.play("chop")

	# one-shot connection for when animation ends
	$AnimatedSprite2D.animation_finished.connect(_on_chop_finished, CONNECT_ONE_SHOT)


func _on_chop_finished():
	player_state = "idle"

func play_anim(dir):
	if dir.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif dir.x > 0:
		$AnimatedSprite2D.flip_h = false

	if player_state == "idle":
		$AnimatedSprite2D.play("idle")

	if player_state == "run":
		$AnimatedSprite2D.play("run")
		
	
