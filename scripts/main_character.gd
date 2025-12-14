extends CharacterBody2D
class_name Player

const SPEED = 100.0
var player_state

@onready var inventory_ui = $InventoryUI

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
	
	# NEW: Toggle Inventory Input
	if Input.is_action_just_pressed("toggle_inventory"):
		# Switch between visible and invisible
		inventory_ui.visible = !inventory_ui.visible
	
	if Input.is_action_just_pressed("chop"):
		start_chop()
	
	play_anim(direction)
	

func start_chop():
	player_state = "chop"
	$AnimatedSprite2D.play("chop")
	
	# Get everything touching our AxeHitbox
	var bodies = $AxeHitbox.get_overlapping_bodies()
	
	for body in bodies:
		# Check if the body has the 'chop_hit' function (is it a tree?)
		if body.has_method("chop_hit"):
			body.chop_hit()
			# Optional: break here if you only want to hit 1 tree at a time

	# one-shot connection for when animation ends
	$AnimatedSprite2D.animation_finished.connect(_on_chop_finished, CONNECT_ONE_SHOT)


func _on_chop_finished():
	player_state = "idle"

func play_anim(dir):
	if dir.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AxeHitbox.position.x = -20
	elif dir.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AxeHitbox.position.x = 20

	if player_state == "idle":
		$AnimatedSprite2D.play("idle")

	if player_state == "run":
		$AnimatedSprite2D.play("run")
		

func add_to_inventory(item_name):
	# 1. Update the visual UI
	inventory_ui.add_item(item_name)
	
	# 2. (Optional) Keep a data list if you want to save the game later
	# inventory_data.append(item_name)
