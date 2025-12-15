extends Node2D

# Path back to your main world
# UPDATE THIS if your world scene is named differently!
var world_scene = "res://scenes/world.tscn"

@onready var exit_ui = $ExitUI
@onready var btn_yes = $ExitUI/Panel/BtnYes
@onready var btn_no = $ExitUI/Panel/BtnNo
func _ready():
	exit_ui.visible = false
	# Connect buttons
	btn_yes.pressed.connect(_on_yes_pressed)
	btn_no.pressed.connect(_on_no_pressed)

# --- DETECTION ---
func _on_exit_area_body_entered(body):
	if body is Player:
		exit_ui.visible = true

func _on_exit_area_body_exited(body):
	if body is Player:
		exit_ui.visible = false

# --- TRANSITION ---
func _on_yes_pressed():
	# Retrieve the saved spot from the backpack
	if Global.stored_world_position != null:
		Global.next_player_position = Global.stored_world_position
	
	# Now go back to the world
	get_tree().change_scene_to_file(world_scene)

func _on_no_pressed():
	exit_ui.visible = false


func _on_btn_yes_pressed() -> void:
	pass # Replace with function body.


func _on_btn_no_pressed() -> void:
	pass # Replace with function body.
