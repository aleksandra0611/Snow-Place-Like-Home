extends CharacterBody2D

var player_in_range = false
var nearby_player = null
var shop_open = false

# Preload the UI scene we just made
var shop_scene = preload("res://scenes/shop_ui.tscn") # CHECK YOUR PATH

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("idle")

func _on_chat_detection_area_body_entered(body):
	if body is Player:
		player_in_range = true
		nearby_player = body
		# Optional: Show a little "E" icon above wizard?

func _on_chat_detection_area_body_exited(body):
	if body is Player:
		player_in_range = false
		nearby_player = null
		shop_open = false # Close logic handled by UI mostly

func _input(event):
	if player_in_range and Input.is_action_just_pressed("interact") and not shop_open:
		open_shop()

func open_shop():
	if nearby_player:
		shop_open = true
		
		# Create the UI
		var shop = shop_scene.instantiate()
		shop.set_player_reference(nearby_player)
		
		# Connect the "tree_exited" signal so we know when it closes
		shop.tree_exited.connect(_on_shop_closed)
		
		get_parent().add_child(shop)

func _on_shop_closed():
	shop_open = false


func _on_chat_detection_area_tree_exited():
	pass # Replace with function body.
