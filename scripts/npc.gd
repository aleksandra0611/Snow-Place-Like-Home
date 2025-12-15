extends StaticBody2D

# --- DIALOGUE CONFIG ---
# You can type your sentences here!
var dialogue_lines = [
	"Greetings, traveler...",
	"It has been ages since anyone answered this road.",
	"You may not realize it yet, but you are among the last souls left in this kingdom.",
	"...",
	"This fire beside me burned for millenia",
	"It held back the endless cold when cities still stood and people filled these streets.",
	"Now… its flame is fading.",
	"The people abandoned this land long ago.",
	"Only the fire kept this place from freezing into silence.",
	"I have little strength left, but one hope remains.",
	"Will you gather wood from the forest and help the fire burn a while longer?",
	"It is all that stands between this land and eternal frost.",
	"The woods are dangerous.",
	"Vicious beasts roam there, and they grow far more aggressive once night falls.",
	"If your strength begins to fail, seek out the wizard’s shop.",
	"He may yet offer aid to those still brave enough to walk this world.",
	"Tread carefully, traveler, and may the flame guide you.”"
]

var current_line_index = 0
var player_in_range = false

# NODES
@onready var label = $SpeechLabel
@onready var sprite = $Sprite2D

func _ready():
	# Hide text at start
	label.visible = false

func _input(event):
	# If player is close and presses "Interact" (E), show next line
	if player_in_range and event.is_action_pressed("interact"):
		advance_dialogue()

func _on_dialogue_area_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		current_line_index = 0 # Reset to start
		show_current_line()
		
		# Make him look at the player (Optional)
		face_player(body)

func _on_dialogue_area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		label.visible = false # Hide text when you walk away

func show_current_line():
	label.text = dialogue_lines[current_line_index]
	label.visible = true

func advance_dialogue():
	# Go to next line
	current_line_index += 1
	
	# If we have lines left, show them
	if current_line_index < dialogue_lines.size():
		show_current_line()
	else:
		# If no lines left, restart or close?
		# Let's loop back to the last line, or close it.
		# Option A: Close it
		# label.visible = false 
		
		# Option B: Keep showing the last line (Current choice)
		current_line_index = dialogue_lines.size() - 1

func face_player(player):
	# Simple flip logic since we only have 1 image
	if player.global_position.x < global_position.x:
		sprite.flip_h = false # Look Left (adjust based on your image)
	else:
		sprite.flip_h = true  # Look Right
