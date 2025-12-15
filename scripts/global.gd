extends Node

var next_player_position = null
var stored_world_position = null

var saved_inventory = []
var player_health = 10
var tree_respawn_times = {}
var player_arrows = 20
var current_day_time = 0.0
var is_night = false

signal night_started
signal day_started
