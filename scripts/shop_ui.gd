extends CanvasLayer

var player = null
var wood_price = 1 

# --- CONFIGURATION ---
var shop_items = [
	{ "id": "health_potion", "name": "Health Potion", "price": 2, "icon": "res://art/potions/green_potion.png" },
	{ "id": "super_health_potion", "name": "Super Health Potion", "price": 3, "icon": "res://art/potions/red_potion.png" },
	{ "id": "ultra_health_potion", "name": "Ultra Health Potion", "price": 5, "icon": "res://art/potions/purple_potion.png" }
]

# NODES
@onready var main_menu = $Panel/MainMenu
@onready var buy_menu = $Panel/BuyMenu
@onready var wood_menu = $Panel/WoodMenu 
@onready var wizard_text = $Panel/MainMenu/Label
@onready var btn_back = $Panel/BtnBack

# NEW: Audio Node
@onready var purchase_sfx = $PurchaseSFX 

# WOOD NODES
@onready var spin_box = $Panel/WoodMenu/HBoxContainer/SpinBox
@onready var cost_label = $Panel/WoodMenu/HBoxContainer/CostLabel

func _ready():
	show_main_menu()

func set_player_reference(p):
	player = p

# --- NAVIGATION (Unchanged) ---
func show_main_menu():
	main_menu.visible = true
	buy_menu.visible = false
	wood_menu.visible = false
	btn_back.visible = false
	wizard_text.visible = true
	wizard_text.text = "Greetings! How can I help?"

func show_buy_menu():
	main_menu.visible = false
	buy_menu.visible = true
	wood_menu.visible = false
	btn_back.visible = true
	wizard_text.visible = true
	wizard_text.text = "Pick a potion..."
	_refresh_potion_list()

func show_wood_menu():
	main_menu.visible = false
	buy_menu.visible = false
	wood_menu.visible = true
	btn_back.visible = true
	wizard_text.visible = false 
	spin_box.value = 4 
	_update_wood_cost(4)

# --- POTION LOGIC ---
func _refresh_potion_list():
	for child in buy_menu.get_children():
		child.queue_free()
	for item in shop_items:
		var btn = Button.new()
		btn.text = item["name"] + " - " + str(item["price"]) + " Souls"
		btn.icon = load(item["icon"])
		btn.expand_icon = true
		btn.pressed.connect(_on_item_bought.bind(item))
		buy_menu.add_child(btn)

func _on_item_bought(item_data):
	var cost = item_data["price"]
	
	# CHECK IF SUCCESSFUL
	if player.get_item_count("soul") >= cost:
		player.remove_items("soul", cost)
		player.add_to_inventory(item_data["id"]) 
		wizard_text.text = "Purchased " + item_data["name"] + "!"
		
		# PLAY SOUND HERE
		purchase_sfx.play() 
	else:
		wizard_text.text = "Not enough souls!"
		# No sound here, so it stays silent on failure

# --- WOOD LOGIC ---

func _on_spin_box_value_changed(value):
	_update_wood_cost(value)

func _update_wood_cost(quantity):
	var total_cost = quantity / 4 
	cost_label.text = str(total_cost)

func _on_btn_confirm_wood_pressed():
	var quantity = int(spin_box.value)
	var total_cost = quantity / 4
	
	# CHECK IF SUCCESSFUL
	if player.get_item_count("soul") >= total_cost:
		player.remove_items("soul", total_cost)
		for i in range(quantity):
			player.add_to_inventory("log")
			
		wizard_text.visible = true
		wizard_text.text = "Here is your wood."
		
		# PLAY SOUND HERE
		purchase_sfx.play()
	else:
		wizard_text.visible = true
		wizard_text.text = "You need " + str(total_cost) + " souls for that."
		# No sound here

# --- MAIN BUTTON SIGNALS (Unchanged) ---
func _on_btn_buy_pressed():
	show_buy_menu()

func _on_btn_wood_pressed(): 
	show_wood_menu()

func _on_btn_leave_pressed():
	queue_free()

func _on_btn_back_pressed():
	show_main_menu()
