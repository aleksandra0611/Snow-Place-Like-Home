extends Control

@onready var grid = $Panel/GridContainer

func add_item(item_name):
	var item_added = false

	# Check if we already have a stack of this item
	for slot in grid.get_children():
		# Check if slot is NOT empty
		if slot.get_child_count() > 0:
			# Get the icon node (it's the first child usually, but let's be safe)
			# We'll assume the texture rect is always the first child if it exists,
			# but we have a label there now too!
			
			# Let's find the TextureRect specifically
			var icon = null
			for child in slot.get_children():
				if child is TextureRect:
					icon = child
					break
			
			# If we found an icon, check if it matches our new item
			if icon and icon.texture.resource_path.ends_with(item_name + ".png"):
				# Found a match! Now check the count.
				var label = slot.get_node("AmountLabel")
				var current_amount = 1
				
				if label.visible:
					current_amount = int(label.text)
				
				# If stack is not full (less than 12)
				if current_amount < 12:
					current_amount += 1
					label.text = str(current_amount)
					label.visible = true # Show the number now
					print("Added to stack! Total: " + str(current_amount))
					item_added = true
					return 

	# If we didn't add it to a stack, find an empty slot
	if not item_added:
		for slot in grid.get_children():
			# An empty slot ONLY has the hidden AmountLabel, so child count is 1.
			# If you deleted the labels, count is 0. 
			# Safest check: look for a TextureRect.
			var has_item = false
			for child in slot.get_children():
				if child is TextureRect:
					has_item = true
			
			if not has_item:
				# FOUND EMPTY SLOT
				var icon = TextureRect.new()
				if item_name == "log":
					icon.texture = preload("res://art/environment/log.png")
				
				# Setup Icon visuals
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.custom_minimum_size = Vector2(25, 25)
				
				slot.add_child(icon)
				print("Created new stack.")
				return 
