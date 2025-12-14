extends Control

@onready var grid = $Panel/GridContainer

func add_item(item_name):
	var item_added = false

	# STEP 1: CHECK FOR EXISTING STACKS
	for slot in grid.get_children():
		var icon = null
		
		# Find the existing icon
		for child in slot.get_children():
			if child is TextureRect:
				icon = child
				break
		
		# If found and matches
		if icon and icon.texture.resource_path.ends_with(item_name + ".png"):
			var label = slot.get_node("AmountLabel")
			var current_amount = 1
			if label.visible:
				current_amount = int(label.text)
			
			if current_amount < 12:
				current_amount += 1
				label.text = str(current_amount)
				label.visible = true 
				print("Added " + item_name + " to stack! Total: " + str(current_amount))
				
				# Optional: Update tooltip to show count? 
				# icon.tooltip_text = item_name + " x" + str(current_amount)
				
				item_added = true
				return 

	# STEP 2: FIND AN EMPTY SLOT
	if not item_added:
		for slot in grid.get_children():
			# Check if slot has an icon
			var has_item = false
			for child in slot.get_children():
				if child is TextureRect:
					has_item = true
					break
			
			if not has_item:
				# FOUND EMPTY SLOT!
				var icon = TextureRect.new()
				
				# --- 1. SETUP IMAGE ---
				if item_name == "log":
					icon.texture = preload("res://art/environment/log.png")
				elif item_name == "soul":
					icon.texture = preload("res://art/soul/soul.png")
				
				# --- 2. CENTER THE ICON ---
				# This tells the icon to stick to the center of the slot Panel
				icon.set_anchors_preset(Control.PRESET_FULL_RECT)
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				
				# --- 3. ADD HOVER TEXT (TOOLTIP) ---
				# Godot will automatically show this text when hovering
				icon.tooltip_text = item_name.capitalize() # e.g., turns "log" into "Log"
				
				slot.add_child(icon)
				slot.move_child(icon, 0)
				print("Created new " + item_name + " stack.")
				return
