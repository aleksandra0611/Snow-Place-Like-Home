extends CharacterBody2D

var shop_open = false
var nearby_player = null

# Preload the UI scene
var shop_scene = preload("res://scenes/shop_ui.tscn") 

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("idle")

func _on_chat_detection_area_body_entered(body):
	# AUTOMATIC OPEN: If player enters and shop isn't open yet
	if body is Player and not shop_open:
		nearby_player = body
		open_shop()

func _on_chat_detection_area_body_exited(body):
	# AUTOMATIC CLOSE: If player leaves, kill the shop window
	if body is Player:
		nearby_player = null
		# We will handle closing via the UI itself mostly, 
		# but we reset our tracking variable here.
		shop_open = false
		
		# Optional: Find the existing shop window and delete it 
		# so it doesn't stay on screen if you run away.
		var existing_shop = get_parent().get_node_or_null("ShopUI")
		if existing_shop:
			existing_shop.queue_free()

func open_shop():
	shop_open = true
	var shop = shop_scene.instantiate()
	shop.set_player_reference(nearby_player)
	shop.tree_exited.connect(_on_shop_closed)
	get_parent().add_child(shop)

func _on_shop_closed():
	shop_open = false
