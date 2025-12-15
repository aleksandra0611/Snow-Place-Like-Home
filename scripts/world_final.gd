extends Node2D

@onready var day_anim = $AnimationPlayer

@export var next_world_path: String = "res://scenes/world_wizard.tscn" 

# Where should the player spawn in the NEXT world?
# (e.g., The left side of the screen: x=50, y=300)
@export var next_spawn_xy: Vector2 = Vector2(50, 10)

var night_start_time = 180.0
var night_end_time = 300.0 

func _ready():
	if Global.next_player_position != null:
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			player.global_position = Global.next_player_position
			Global.next_player_position = null 
	
	day_anim.play("cycle")
	day_anim.seek(Global.current_day_time)
	
	if Global.current_day_time >= night_start_time:
		Global.is_night = true
	else:
		Global.is_night = false

	if has_node("ExitZone"):
		$ExitZone.body_entered.connect(_on_exit_zone_entered)


func _process(_delta):
	Global.current_day_time = day_anim.current_animation_position
	var time = Global.current_day_time
	
	if time >= night_start_time and not Global.is_night:
		print("Night has fallen.")
		Global.is_night = true
		Global.night_started.emit() 

	if time < 10.0 and Global.is_night:
		print("Sun is rising.")
		Global.is_night = false
		Global.day_started.emit()

# --- NEW TRANSITION FUNCTION ---
func _on_exit_zone_entered(body):
	if body.is_in_group("Player"):
		print("Transitioning to next world...")
		call_deferred("change_level")

func change_level():
	# 1. Save the position where we want to spawn in the NEW world
	Global.next_player_position = next_spawn_xy
	
	get_tree().change_scene_to_file(next_world_path)
