extends Node2D

# --- 1. Inspector Slots ---
@export var mission_row_scene: PackedScene 
@export var box_unchecked: Texture2D       
@export var box_checked: Texture2D         

# --- 2. Node References ---
@onready var item_container = $mission_list/itemlist_container
@onready var basket_label = $basket/basketlabel
@onready var progress_bar = $TextureProgressBar
@onready var game_timer = $timer/gametimer
@onready var timer_label = $timer/timerlabel
@onready var message_label = $MessageLabel 

# Magnet Nodes
@onready var magnet_sprite = $magnet
@onready var magnet_button = $magnet/magnet_button

# UI Board Nodes
@onready var ui_layer = $ui_layer
@onready var blur_overlay = $ui_layer/blur_overlay # ColorRect with Blur Shader
@onready var win_board = $ui_layer/win_board
@onready var collect_btn = $ui_layer/win_board/collect_rewards
@onready var back_btn = $ui_layer/win_board/back_button
@onready var next_btn = $ui_layer/win_board/next_button

# --- 3. Game Variables ---
var fruit_list = ["Apples", "Oranges", "Bananas", "Grapes", "Pear", "Strawberries", "Milk", "Cheese", "Butter", "Flour", "Carrots", "Cabbage", "Tomato", "Potato", "Eggplant", "Sayote", "Onion", "Garlic", "Bokchoy", "Bread"]

var shopping_list_data = {} 
var current_basket_count = 0
var total_needed = 0
var game_over = false
var magnet_used = false 
var original_magnet_scale: Vector2

func _ready():
	win_board.hide()
	if blur_overlay: blur_overlay.hide() 
	if message_label: message_label.text = ""
	timer_label.add_theme_color_override("font_color", Color.RED)
	
	# Save your editor scale for the magnet pulse
	original_magnet_scale = magnet_sprite.scale
	
	# CONTAINER STABILITY: Force the list to stay inside the wooden scroll area
	item_container.clip_contents = true
	item_container.custom_minimum_size = Vector2(250, 380)
	item_container.size = Vector2(250, 380)
	
	setup_hover_animations()
	connect_win_buttons()
	
	# Reset Magnet State for Level Start
	magnet_used = false
	magnet_button.disabled = false
	magnet_sprite.self_modulate = Color.WHITE
	
	if magnet_button:
		if not magnet_button.pressed.is_connected(_on_magnet_pressed):
			magnet_button.pressed.connect(_on_magnet_pressed)
	
	generate_shopping_list()
	setup_market_buttons()
	game_timer.start(60)

func _process(_delta):
	if !game_over:
		update_timer_display()

# --- 4. Magical Magnet Feature ---
func _on_magnet_pressed():
	if game_over or magnet_used: return
	
	var target_item = ""
	var max_amount = -1
	
	# Find item with the highest quantity remaining
	for item in shopping_list_data:
		if shopping_list_data[item] > max_amount:
			max_amount = shopping_list_data[item]
			target_item = item
			
	if target_item != "" and max_amount > 0:
		magnet_used = true 
		
		# Pulse Effect: Pop up then go back to original size
		var tween = create_tween()
		var pop_scale = original_magnet_scale * 1.3
		tween.tween_property(magnet_sprite, "scale", pop_scale, 0.1)
		tween.tween_property(magnet_sprite, "scale", original_magnet_scale, 0.1)
		
		# Disable & Gray Out (1 Use Only)
		magnet_button.disabled = true
		magnet_sprite.self_modulate = Color(0.3, 0.3, 0.3) 
		
		show_message("Magnet pulled all " + target_item + "!")
		
		# Complete the item
		shopping_list_data[target_item] = 0
		current_basket_count += 1
		
		update_list_visuals(target_item)
		update_basket_ui()
		create_tween().tween_property(progress_bar, "value", current_basket_count, 0.2)
		
		if current_basket_count == total_needed:
			win_game()
	else:
		show_message("Nothing left to magnetize!")

# --- 5. UI Animations & Button Logic ---
func setup_hover_animations():
	var buttons = [collect_btn, back_btn, next_btn]
	for btn in buttons:
		btn.pivot_offset = btn.size / 2
		btn.mouse_entered.connect(func(): 
			create_tween().tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)
		)
		btn.mouse_exited.connect(func(): 
			create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
		)

func connect_win_buttons():
	if !back_btn.pressed.is_connected(_on_back_pressed):
		back_btn.pressed.connect(_on_back_pressed)
	if !next_btn.pressed.is_connected(_on_next_pressed):
		next_btn.pressed.connect(_on_next_pressed)
	if !collect_btn.pressed.is_connected(_on_collect_pressed):
		collect_btn.pressed.connect(_on_collect_pressed)

func _on_back_pressed(): get_tree().reload_current_scene()
func _on_next_pressed(): pass
func _on_collect_pressed(): 
	win_board.hide()
	if blur_overlay: blur_overlay.hide()

# --- 6. Mission List Logic ---
func generate_shopping_list():
	current_basket_count = 0
	total_needed = 0
	shopping_list_data.clear()
	game_over = false
	
	for child in item_container.get_children():
		child.queue_free()
	
	var tasks_count = randi_range(8, 10)
	var available_fruits = fruit_list.duplicate()
	available_fruits.shuffle()
	
	for i in range(tasks_count):
		var fruit_name = available_fruits[i]
		var amount = randi_range(1, 6)
		shopping_list_data[fruit_name] = amount
		total_needed += 1
		
		var new_row = mission_row_scene.instantiate()
		new_row.name = fruit_name
		new_row.scale = Vector2(0.9, 0.9)
		
		var label = new_row.get_node("itemtext")
		label.text = str(amount) + "x " + fruit_name
		label.add_theme_color_override("font_color", Color.BLACK)
		
		var box = new_row.get_node("checkbox")
		box.texture = box_unchecked
		box.custom_minimum_size = Vector2(35, 35)
		box.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		box.show() # Keep boxes visible
		
		item_container.add_child(new_row)
		
	progress_bar.max_value = total_needed
	progress_bar.value = 0
	update_basket_ui()

func _on_item_tapped(item_name: String):
	if game_over: return
	if shopping_list_data.has(item_name):
		if shopping_list_data[item_name] > 0:
			shopping_list_data[item_name] -= 1
			if shopping_list_data[item_name] == 0:
				current_basket_count += 1
			update_list_visuals(item_name)
			update_basket_ui()
			create_tween().tween_property(progress_bar, "value", current_basket_count, 0.2)
			if current_basket_count == total_needed: win_game()
		else:
			show_message(item_name + " is already complete!")
	else:
		show_message(item_name + " is not on the list!")

func update_list_visuals(item_name: String):
	var row = item_container.get_node(item_name)
	if row:
		var label = row.get_node("itemtext")
		var box = row.get_node("checkbox")
		if shopping_list_data[item_name] <= 0:
			label.text = item_name
			label.add_theme_color_override("font_color", Color.DARK_GREEN)
			box.texture = box_checked
		else:
			label.text = str(shopping_list_data[item_name]) + "x " + item_name
			label.add_theme_color_override("font_color", Color.BLACK)
		box.show()

func show_message(text: String):
	if message_label:
		message_label.text = text
		message_label.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_interval(1.5)
		tween.tween_property(message_label, "modulate:a", 0.0, 0.5)

# --- 7. Core Game Loop ---
func win_game():
	game_over = true
	game_timer.stop()
	
	if blur_overlay: blur_overlay.show()
	win_board.show()
	
	win_board.pivot_offset = win_board.size / 2
	win_board.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(win_board, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC)

func update_timer_display():
	var time_left = game_timer.time_left
	var minutes = floor(time_left / 60.0)
	var seconds = int(time_left) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	if time_left <= 0: lose_game()

func lose_game():
	game_over = true
	timer_label.text = "00:00"

func update_basket_ui():
	basket_label.text = str(current_basket_count) + " / " + str(total_needed)

func setup_market_buttons():
	var market_stalls = [$freshfruits_market, $dairy_market, $veggie_market, $bread_market]
	for stall in market_stalls:
		if stall == null: continue
		for button in stall.get_children():
			if button is TextureButton:
				var fruit_key = button.name.split("_")[0].capitalize()
				if !button.pressed.is_connected(_on_item_tapped):
					button.pressed.connect(_on_item_tapped.bind(fruit_key))
