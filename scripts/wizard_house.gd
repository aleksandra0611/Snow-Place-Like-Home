extends Node2D

# The path to your INTERIOR scene (Make sure you create this scene!)
# If you haven't made it yet, just create a new empty scene and save it as "wizard_shop_interior.tscn"
var shop_interior_scene = "res://scenes/wizard_shop.tscn"

@onready var door_ui = $DoorUI
@onready var btn_yes = $DoorUI/Panel/BtnYes
@onready var btn_no = $DoorUI/Panel/BtnNo

var player_at_door = false

func _ready():
	# Ensure UI is hidden at start
	door_ui.visible = false
	
	# Connect button signals via code (or do it in the editor)
	btn_yes.pressed.connect(_on_yes_pressed)
	btn_no.pressed.connect(_on_no_pressed)

# --- DOOR DETECTION ---
func _on_door_area_body_entered(body):
	if body is Player:
		player_at_door = true
		door_ui.visible = true # Show the pop-up

func _on_door_area_body_exited(body):
	if body is Player:
		player_at_door = false
		door_ui.visible = false # Hide the pop-up if they walk away

# --- BUTTON LOGIC ---
func _on_yes_pressed():
	# Save the position for LATER (in the backpack)
	Global.stored_world_position = global_position + Vector2(0, 50)
	
	# Do NOT set next_player_position here!
	# This ensures we spawn at the shop's default start point (0,0)
	
	get_tree().change_scene_to_file(shop_interior_scene)

func _on_no_pressed():
	# Just close the menu
	door_ui.visible = false


func _on_btn_yes_pressed() -> void:
	pass # Replace with function body.


func _on_btn_no_pressed() -> void:
	pass # Replace with function body.
