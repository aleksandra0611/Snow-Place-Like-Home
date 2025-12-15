extends Control

var game_scene_path = "res://scenes/world_final.tscn"

func _ready():
	$VBoxContainer/BtnPlay.pressed.connect(_on_play_pressed)
	$VBoxContainer/BtnQuit.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	print("Loading game...")
	get_tree().change_scene_to_file(game_scene_path)

func _on_quit_pressed():
	print("Quitting game...")
	get_tree().quit()
