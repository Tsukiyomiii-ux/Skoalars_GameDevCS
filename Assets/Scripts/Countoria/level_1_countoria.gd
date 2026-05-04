extends Node2D

# --- 1. Inspector Slots ---
@export var mission_row_scene: PackedScene 
@export var box_unchecked: Texture2D       
@export var box_checked: Texture2D         

# --- 2. Node References ---
@onready var item_container = $mission_list/itemlist_container
@onready var basket_label = $basket/basketlabel
@onready var progress_bar = $progressbar_frame/TextureProgressBar
@onready var game_timer = $timer/gametimer
@onready var timer_label = $timer/timerlabel
@onready var message_label = $progressbar_frame/MessageLabel 

# Magnet Nodes
@onready var magnet_sprite = $magnet
@onready var magnet_button = $magnet/magnet_button

# REWARD NODES
@onready var freeze_icon = $ui_layer/win_board/freeze_time
@onready var gem_icon = $ui_layer/win_board/gemicon

# UI Board Nodes
@onready var ui_layer = $ui_layer
@onready var blur_overlay = $ui_layer/blur_overlay 
@onready var win_board = $ui_layer/win_board
@onready var collect_btn = $ui_layer/win_board/collect_rewards
@onready var back_btn = $ui_layer/win_board/back_button
@onready var next_btn = $ui_layer/win_board/next_button

# --- LOSE BOARD & HOURGLASS ---
@onready var lose_board = $ui_layer/lose_board
@onready var hourglass_anim = $ui_layer/lose_board/background2/hourglass 
@onready var tryagain_btn = $ui_layer/lose_board/tryagain_button
@onready var quit_btn = $ui_layer/lose_board/quit_button

@onready var correct_sound = $correct_sound
@onready var wrong_sound = $wrong_sound
@onready var tapping_sound = $tapping_sound 

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
	if lose_board: lose_board.hide()
	if blur_overlay: blur_overlay.hide() 
	if message_label: message_label.text = ""
	timer_label.add_theme_color_override("font_color", Color.RED)
	
	if freeze_icon: freeze_icon.pivot_offset = freeze_icon.size / 2
	if gem_icon: gem_icon.pivot_offset = gem_icon.size / 2
	
	original_magnet_scale = magnet_sprite.scale
	
	item_container.clip_contents = true
	item_container.custom_minimum_size = Vector2(250, 380)
	item_container.size = Vector2(250, 380)
	
	setup_hover_animations()
	connect_win_buttons()
	connect_lose_buttons()
	
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

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if tapping_sound: tapping_sound.play()

# --- 4. Magical Magnet Feature ---
func _on_magnet_pressed():
	if game_over or magnet_used: return
	var target_item = ""
	var max_amount = -1
	for item in shopping_list_data:
		if shopping_list_data[item] > max_amount:
			max_amount = shopping_list_data[item]
			target_item = item
	if target_item != "" and max_amount > 0:
		if correct_sound: correct_sound.play()
		magnet_used = true 
		var tween = create_tween()
		tween.tween_property(magnet_sprite, "scale", original_magnet_scale * 1.3, 0.1)
		tween.tween_property(magnet_sprite, "scale", original_magnet_scale, 0.1)
		magnet_button.disabled = true
		magnet_sprite.self_modulate = Color(0.3, 0.3, 0.3) 
		show_message("Magnet pulled all " + target_item + "!")
		shopping_list_data[target_item] = 0
		current_basket_count += 1
		update_list_visuals(target_item)
		update_basket_ui()
		create_tween().tween_property(progress_bar, "value", current_basket_count, 0.2)
		if current_basket_count == total_needed: win_game()

# --- 5. UI Animations & Button Logic ---
func setup_hover_animations():
	var buttons = [collect_btn, back_btn, next_btn, tryagain_btn, quit_btn]
	for btn in buttons:
		if btn:
			btn.pivot_offset = btn.size / 2
			btn.mouse_entered.connect(func(): create_tween().tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1))
			btn.mouse_exited.connect(func(): create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1))

func connect_win_buttons():
	if back_btn and not back_btn.pressed.is_connected(_on_back_pressed):
		back_btn.pressed.connect(_on_back_pressed)
	if next_btn and not next_btn.pressed.is_connected(_on_next_pressed):
		next_btn.pressed.connect(_on_next_pressed)
	if collect_btn and not collect_btn.pressed.is_connected(_on_collect_pressed):
		collect_btn.pressed.connect(_on_collect_pressed)

func connect_lose_buttons():
	if tryagain_btn and not tryagain_btn.pressed.is_connected(_on_reload_scene):
		tryagain_btn.pressed.connect(_on_reload_scene)
	if quit_btn and not quit_btn.pressed.is_connected(_on_quit_pressed):
		quit_btn.pressed.connect(_on_quit_pressed)

# --- NAVIGATION LOGIC ---
func _on_back_pressed(): 
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Assets/Scene/Countoria/countoria.tscn")

func _on_reload_scene():
	if is_inside_tree():
		get_tree().reload_current_scene()

func _on_next_pressed():
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Assets/Scene/Countoria/level_2_countoria.tscn")

# UPDATED: Directs to Countoria Island instead of quitting the app
func _on_quit_pressed():
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Assets/Scene/Countoria/countoria.tscn")

func _on_collect_pressed(): 
	var tween = create_tween().set_parallel(true)
	if freeze_icon:
		tween.tween_property(freeze_icon, "scale", Vector2(1.3, 1.3), 0.1)
		tween.chain().tween_property(freeze_icon, "scale", Vector2(1.0, 1.0), 0.1)
	if gem_icon:
		tween.tween_property(gem_icon, "scale", Vector2(1.3, 1.3), 0.1)
		tween.chain().tween_property(gem_icon, "scale", Vector2(1.0, 1.0), 0.1)

# --- 6. Mission List Logic ---
func generate_shopping_list():
	current_basket_count = 0
	total_needed = 0
	shopping_list_data.clear()
	game_over = false
	for child in item_container.get_children(): child.queue_free()
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
		new_row.get_node("itemtext").text = str(amount) + "x " + fruit_name
		new_row.get_node("itemtext").add_theme_color_override("font_color", Color.BLACK)
		var box = new_row.get_node("checkbox")
		box.texture = box_unchecked
		box.custom_minimum_size = Vector2(35, 35)
		box.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		box.show()
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
				if correct_sound: correct_sound.play()
				current_basket_count += 1
			update_list_visuals(item_name)
			update_basket_ui()
			create_tween().tween_property(progress_bar, "value", current_basket_count, 0.2)
			if current_basket_count == total_needed: win_game()
		else:
			if wrong_sound: wrong_sound.play()
			apply_time_penalty(2)
			show_message(item_name + " is already complete!")
	else:
		if wrong_sound: wrong_sound.play()
		apply_time_penalty(2)
		show_message(item_name + " is not on the list!")

# --- ORIGINAL PENALTY FUNCTION (NO CHANGES) ---
func apply_time_penalty(amount: float):
	var current_time = game_timer.time_left
	game_timer.stop()
	game_timer.start(max(0.1, current_time - amount))
	if timer_label:
		var penalty_label = Label.new()
		penalty_label.text = "- " + str(amount)
		penalty_label.add_theme_color_override("font_color", Color.RED)
		penalty_label.position = timer_label.global_position + Vector2(20, -20)
		add_child(penalty_label)
		var t = create_tween()
		t.tween_property(penalty_label, "position:y", penalty_label.position.y - 60, 0.6)
		t.parallel().tween_property(penalty_label, "modulate:a", 0.0, 0.6)
		t.tween_callback(penalty_label.queue_free)

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

func show_message(text: String):
	if message_label:
		message_label.text = text
		message_label.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_interval(1.5)
		tween.tween_property(message_label, "modulate:a", 0.0, 0.5)

func win_game():
	game_over = true
	game_timer.stop()
	if blur_overlay: blur_overlay.show()
	win_board.show()
	win_board.pivot_offset = win_board.size / 2
	win_board.scale = Vector2(0.5, 0.5)
	create_tween().tween_property(win_board, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC)

func update_timer_display():
	var time_left = game_timer.time_left
	timer_label.text = "%02d:%02d" % [floor(time_left / 60.0), int(time_left) % 60]
	if time_left <= 0: lose_game()

# --- LOSE LOGIC WITH ANIMATION TRIGGER ---
func lose_game(): 
	if game_over: return
	game_over = true
	game_timer.stop()
	timer_label.text = "00:00"
	if blur_overlay: blur_overlay.show()
	if lose_board:
		lose_board.show()
		
		# TRIGGER THE DESIGN ANIMATION HERE
		if hourglass_anim:
			hourglass_anim.play("default")
			
		ui_layer.move_child(lose_board, ui_layer.get_child_count() - 1)
		lose_board.pivot_offset = lose_board.size / 2
		lose_board.scale = Vector2(0.5, 0.5)
		create_tween().tween_property(lose_board, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC)

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

func _on_back_button_pressed() -> void:
	_on_back_pressed()

func _on_next_button_pressed() -> void:
	_on_next_pressed()

# Signal handler from Inspector
func _on_quit_button_pressed() -> void:
	_on_quit_pressed()
