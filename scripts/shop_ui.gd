extends CanvasLayer

var player = null

@onready var wizard_text = $Panel/Label
@onready var status_text = $Panel/StatusLabel # Make sure you created this Label

func _ready():
	# Hide status initially
	status_text.text = ""

func set_player_reference(p):
	player = p

# --- BUTTON SIGNALS (Connect these in Node tab!) ---

func _on_btn_buy_pressed():
	# Simple Shop: Buy a Potion for 1 Soul
	var cost = 1
	if player.get_item_count("soul") >= cost:
		player.remove_items("soul", cost)
		player.add_to_inventory("potion") # Ensure you have a potion.png!
		wizard_text.text = "A wise choice!"
		status_text.text = "-1 Soul"
	else:
		wizard_text.text = "You lack the souls for this..."
		status_text.text = "Need 1 Soul"

func _on_btn_sell_pressed():
	# Simple Sell: Sell 1 Soul for nothing (placeholder for now)
	# Or maybe sell a "log" for a "soul"? Let's do that.
	if player.get_item_count("log") >= 1:
		player.remove_items("log", 1)
		player.add_to_inventory("soul")
		wizard_text.text = "I will take that wood."
		status_text.text = "+1 Soul"
	else:
		wizard_text.text = "You have no logs to trade."

func _on_btn_leave_pressed():
	queue_free() # Close the shop
