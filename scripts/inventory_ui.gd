extends Control

@onready var grid = $Panel/GridContainer
@onready var player = get_parent() # Link back to the player so we can heal him

# --- ADDING ITEMS ---
func add_item(item_name):
	var item_added = false

	# 1. CHECK FOR EXISTING STACKS
	for slot in grid.get_children():
		var icon = null
		for child in slot.get_children():
			if child is TextureRect:
				icon = child
				break
		
		if icon and icon.has_meta("id") and icon.get_meta("id") == item_name:
			var label = slot.get_node("AmountLabel")
			var current_amount = 1
			if label.visible:
				current_amount = int(label.text)
			
			if current_amount < 12:
				current_amount += 1
				label.text = str(current_amount)
				label.visible = true 
				print("Added " + item_name + " to stack! Total: " + str(current_amount))
				item_added = true
				return 

	# 2. FIND AN EMPTY SLOT
	if not item_added:
		for slot in grid.get_children():
			var has_item = false
			for child in slot.get_children():
				if child is TextureRect:
					has_item = true
					break
			
			if not has_item:
				# FOUND EMPTY SLOT!
				var icon = TextureRect.new()
				icon.set_meta("id", item_name)
				
				# --- IMAGE ASSIGNMENT ---
				if item_name == "log":
					icon.texture = preload("res://art/environment/log.png")
				elif item_name == "soul":
					icon.texture = preload("res://art/soul/soul.png")
				elif item_name == "health_potion":
					icon.texture = preload("res://art/potions/green_potion.png")
				elif item_name == "super_health_potion":
					icon.texture = preload("res://art/potions/red_potion.png")
				elif item_name == "ultra_health_potion":
					icon.texture = preload("res://art/potions/purple_potion.png")
					
				icon.set_anchors_preset(Control.PRESET_FULL_RECT)
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.tooltip_text = item_name.capitalize() 
				
				# --- NEW: ENABLE CLICKS ---
				# 1. Connect the input signal so we know when it is clicked
				# We bind the 'item_name' and the 'slot' so the function knows what we clicked
				icon.gui_input.connect(_on_item_clicked.bind(item_name, slot, icon))
				
				slot.add_child(icon)
				slot.move_child(icon, 0)
				print("Created new " + item_name + " stack.")
				return

# --- NEW: CLICK LOGIC ---
func _on_item_clicked(event, item_name, slot, icon):
	if event is InputEventMouseButton and event.pressed:
		
		# --- LEFT CLICK (Use Potions) ---
		if event.button_index == MOUSE_BUTTON_LEFT:
			var heal_amount = 0
			if item_name == "health_potion": heal_amount = 2
			elif item_name == "super_health_potion": heal_amount = 5
			elif item_name == "ultra_health_potion": heal_amount = 9
			
			if heal_amount > 0:
				var used_successfully = player.heal(heal_amount)
				if used_successfully:
					remove_one_item(slot, icon)

		# --- RIGHT CLICK (Craft Arrows) ---
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if item_name == "log":
				# 1. Add arrows to global count
				Global.player_arrows += 2
				
				# 2. Update the UI text on the player
				player.update_arrow_label()
				
				# 3. Print feedback (optional)
				print("Crafted 2 arrows! Total: ", Global.player_arrows)
				
				# 4. Remove the log
				remove_one_item(slot, icon)

func remove_one_item(slot, icon):
	# Check stack size
	var label = slot.get_node("AmountLabel")
	var current_amount = 1
	if label.visible:
		current_amount = int(label.text)
	
	if current_amount > 1:
		current_amount -= 1
		label.text = str(current_amount)
		if current_amount == 1:
			label.visible = false
	else:
		icon.queue_free()

# --- SAVE SYSTEM (Keep existing code) ---
func save_items_to_global():
	var items_list = []
	for slot in grid.get_children():
		var icon = null
		for child in slot.get_children():
			if child is TextureRect:
				icon = child
				break
		if icon and icon.has_meta("id"):
			var id = icon.get_meta("id")
			var count = 1
			var label = slot.get_node("AmountLabel")
			if label.visible:
				count = int(label.text)
			for i in range(count):
				items_list.append(id)
	return items_list

func load_items_from_global(items_list):
	for item_name in items_list:
		add_item(item_name)
