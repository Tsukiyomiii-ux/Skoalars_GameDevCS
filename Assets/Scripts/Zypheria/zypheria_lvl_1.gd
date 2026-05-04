extends Node2D

# 1. DATABASE WITH CLUES AND PATHS
var all_flags = [
	{"name": "ARGENTINA", "clue": "Land of the Tango and the Andes.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/ARGENTINA.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/ARGENTINA.png"},
	{"name": "COSTA RICA", "clue": "Lush 'Pura Vida' rainforest paradise.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/COSTA RICA.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/COSTA RICA.png"},
	{"name": "ECUADOR", "clue": "Named for the Equator; home to the Galápagos.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/ECUADOR.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/ECUADOR.png"},
	{"name": "EGYPT", "clue": "Home of the Great Pyramids and the Nile.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/EGYPT.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/EGYPT.png"},
	{"name": "GUATEMALA", "clue": "Heart of the ancient Maya world.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/GUATEMALA.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/GUATEMALA.png"},
	{"name": "ITALY", "clue": "Land of pizza, pasta, and the Colosseum.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/ITALY.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/ITALY.png"},
	{"name": "JAPAN", "clue": "Land of the rising sun and bullet trains.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/JAPAN.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/JAPAN.png"},
	{"name": "MADAGASCAR", "clue": "The island of lemurs and baobab trees.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/MADAGASCAR.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/MADAGASCAR.png"},
	{"name": "PHILIPPINES", "clue": "Archipelago of 7,000 islands and white beaches.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/PHILIPPINES.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/PHILIPPINES.png"},
	{"name": "SAMOA", "clue": "The volcanic heart of Polynesian culture.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/SAMOA.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/SAMOA.png"},
	{"name": "SPAIN", "clue": "Famous for flamenco dancing and tapas.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/SPAIN.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/SPAIN.png"},
	{"name": "UNITED STATES OF AMERICA", "clue": "Home of Hollywood and the Statue of Liberty.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/UNITED STATES OF AMERICA.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/UNITED STATES OF AMERICA.png"},
	{"name": "AUSTRALIA", "clue": "The 'Land Down Under' with kangaroos.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/AUSTRALIA.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/AUSTRALIA.png"},
	{"name": "BRAZIL", "clue": "Giant rainforests and the Christ the Redeemer statue.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/BRAZIL.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/BRAZIL.png"},
	{"name": "CANADA", "clue": "Land of maple syrup, hockey, and snowy mountains.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/CANADA.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/CANADA.png"},
	{"name": "FRANCE", "clue": "Iconic home of the Eiffel Tower and pastries.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/FRANCE.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/FRANCE.png"},
	{"name": "GREECE", "clue": "The cradle of history and the Parthenon.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/GREECE.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/GREECE.png"},
	{"name": "KENYA", "clue": "Famous for wild African safaris and the Savannah.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/KENYA.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/KENYA.png"},
	{"name": "MEXICO", "clue": "Ancient Mayan ruins and world-famous tacos.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/MEXICO.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/MEXICO.png"},
	{"name": "SOUTH KOREA", "clue": "The global hub of K-Pop and tech.", "flag": "res://Assets/Zypheria/LEVEL1/FLAGS/SOUTH KOREA.png", "btn": "res://Assets/Zypheria/LEVEL1/BUTTONS/SOUTH KOREA.png"}
]

var active_queue = [] 
var score = 0 
var target_score = 10
var correct_answer = ""
var is_transitioning = false 
var missed_flag_names = [] 

# --- GLOBAL TIMER SETTINGS ---
var time_left = 90.0 
var timer_active = false

# --- AUDIO NODES ---
@onready var correct_sound = $CorrectSound
@onready var wrong_sound = $WrongSound

# --- UI NODES ---
@onready var flag_display = $FlagDisplay 
@onready var clue_label = $ClueLabel 
@onready var buttons_container = $VBoxContainer
@onready var popup_layer = $PopupLayer
@onready var progression_bar = $ProgressionBar 
@onready var score_label = $ScoreLabel 
@onready var timer_bar = $FlagTimer      
@onready var timer_label = $TimerLabel   
@onready var clock_sprite = $ClockSprite 

# --- WIN/LOSE POPUPS ---
@onready var win_popup = $PopupLayer/WinPopup
@onready var collect_button = $PopupLayer/WinPopup/MainFrame/CollectButton
@onready var win_next_btn = $PopupLayer/WinPopup/BottomButtons/NextButton
@onready var win_cancel_btn = $PopupLayer/WinPopup/BottomButtons/CancelButton

@onready var lose_popup = $PopupLayer/LosePopup
@onready var try_again_button = $PopupLayer/LosePopup/BottomButtons/TryAgainButton
@onready var quit_button = $PopupLayer/LosePopup/BottomButtons/QuitButton

# --- HINT SYSTEM ---
@onready var hint_scroll = $HintScroll
@onready var dim_overlay = $ColorRect 
@onready var world_map_popup = $WorldMapPopup
@onready var map_timer_label = $WorldMapPopup/MapTimerLabel 

var hint_used = false

func _ready():
	# Connect Choice Buttons
	for btn in buttons_container.get_children():
		if btn is TextureButton:
			btn.pressed.connect(_on_button_pressed.bind(btn))
			btn.mouse_entered.connect(_on_button_hover.bind(btn))
			btn.mouse_exited.connect(_on_button_exit.bind(btn))
	
	# Connect ALL System/Popup Buttons (Explicitly including collect_button)
	var ui_buttons = [hint_scroll, collect_button, win_next_btn, win_cancel_btn, try_again_button, quit_button]
	for btn in ui_buttons:
		if btn:
			btn.mouse_entered.connect(_on_button_hover.bind(btn))
			btn.mouse_exited.connect(_on_button_exit.bind(btn))
	
	if hint_scroll: hint_scroll.pressed.connect(_on_hint_scroll_pressed)
	if collect_button: collect_button.pressed.connect(_on_collect_pressed)
	if win_next_btn: win_next_btn.pressed.connect(_on_next_button_pressed)
	if win_cancel_btn: win_cancel_btn.pressed.connect(_on_cancel_button_pressed)
	if try_again_button: try_again_button.pressed.connect(_on_try_again_pressed)
	if quit_button: quit_button.pressed.connect(_on_quit_pressed)
	
	if timer_bar: timer_bar.max_value = 90.0 

	if win_popup: win_popup.hide()
	if lose_popup: lose_popup.hide()
	if popup_layer: popup_layer.hide()
	if world_map_popup: world_map_popup.hide()
	if dim_overlay: dim_overlay.hide()
	
	start_new_game()

func _process(delta):
	if timer_active and not is_transitioning:
		time_left -= delta
		if timer_bar: timer_bar.value = time_left
		
		var mins = int(time_left) / 60
		var secs = int(time_left) % 60
		if timer_label: 
			timer_label.text = str(mins) + ":" + str(secs).pad_zeros(2)
			
		if clock_sprite:
			if time_left < 10.0:
				clock_sprite.speed_scale = 2.5 
				clock_sprite.modulate = Color(1, 0.4, 0.4) 
			else:
				clock_sprite.speed_scale = 1.0
				clock_sprite.modulate = Color.WHITE
		
		if time_left <= 0:
			on_game_over()

func start_new_game():
	score = 0
	time_left = 90.0 
	timer_active = true
	is_transitioning = false
	hint_used = false 
	
	if hint_scroll:
		hint_scroll.modulate = Color.WHITE 
		hint_scroll.disabled = false
		
	missed_flag_names.clear()
	active_queue = all_flags.duplicate()
	active_queue.shuffle()
	update_progress_ui()
	
	if clue_label: clue_label.text = "" 
	if popup_layer: popup_layer.hide()
	if win_popup: win_popup.hide()
	if lose_popup: lose_popup.hide()
	
	load_level()

func load_level():
	if active_queue.is_empty():
		active_queue = all_flags.duplicate()
		active_queue.shuffle()
	
	is_transitioning = false
	var current_data = active_queue[0]
	correct_answer = current_data["name"]
	
	if clue_label:
		if correct_answer in missed_flag_names:
			clue_label.text = '"' + current_data["clue"] + '"'
		else:
			clue_label.text = ""
			
	if clock_sprite: clock_sprite.play("default")
		
	var flag_tex = load(current_data["flag"])
	if flag_tex: flag_display.texture = flag_tex
	_setup_choice_buttons(current_data)

func _setup_choice_buttons(correct_data):
	var choices = [correct_data]
	var others = all_flags.duplicate()
	others.shuffle()
	for item in others:
		if item["name"] != correct_answer:
			choices.append(item)
		if choices.size() == 5:
			break
	choices.shuffle()
	var ui_buttons = buttons_container.get_children()
	for i in range(ui_buttons.size()):
		if i < ui_buttons.size():
			var btn_tex = load(choices[i]["btn"])
			if btn_tex:
				ui_buttons[i].texture_normal = btn_tex
				ui_buttons[i].set_meta("country_name", choices[i]["name"])
				ui_buttons[i].modulate = Color.WHITE

func _on_hint_scroll_pressed():
	if hint_used or world_map_popup == null or world_map_popup.visible or is_transitioning:
		return
	
	hint_used = true 
	if hint_scroll:
		hint_scroll.modulate = Color(0.3, 0.3, 0.3) 
		hint_scroll.disabled = true 
	
	timer_active = false 
	if clock_sprite: clock_sprite.pause()
	if dim_overlay: dim_overlay.show()
	world_map_popup.show()
	
	var map_time = 10
	while map_time > 0:
		if map_timer_label: map_timer_label.text = "Closing in: " + str(map_time) + "s"
		await get_tree().create_timer(1.0).timeout
		map_time -= 1
	
	world_map_popup.hide()
	if dim_overlay: dim_overlay.hide()
	if not is_transitioning:
		timer_active = true 
		if clock_sprite: clock_sprite.play()

func update_progress_ui():
	if progression_bar: progression_bar.value = score
	if score_label: score_label.text = str(score) + "/" + str(target_score)

func on_game_over():
	timer_active = false
	is_transitioning = false 
	if popup_layer: popup_layer.show()
	if lose_popup: lose_popup.show()
	if win_popup: win_popup.hide()

func _on_try_again_pressed():
	start_new_game()

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/Zypheria/zypheria.tscn")

func _on_button_pressed(btn: TextureButton):
	if is_transitioning: return 
	is_transitioning = true
	
	var chosen_name = btn.get_meta("country_name")
	var current_flag_data = active_queue.pop_front()
	
	if chosen_name == correct_answer:
		if correct_sound: correct_sound.play()
		score += 1
		update_progress_ui()
		btn.modulate = Color(0, 1, 0)
		if correct_answer in missed_flag_names:
			missed_flag_names.erase(correct_answer)
		await get_tree().create_timer(0.5).timeout
	else:
		if wrong_sound: wrong_sound.play()
		btn.modulate = Color(1, 0, 0)
		if not correct_answer in missed_flag_names:
			missed_flag_names.append(correct_answer)
		active_queue.push_back(current_flag_data)
		await get_tree().create_timer(0.8).timeout
	
	if score >= target_score:
		show_win_screen()
	else:
		load_level()

func show_win_screen():
	timer_active = false
	is_transitioning = false 
	if popup_layer: popup_layer.show()
	if win_popup: win_popup.show()
	if lose_popup: lose_popup.hide()

func _on_button_hover(btn: Control):
	if btn == hint_scroll and hint_used: return
	
	# Logic check: Choice buttons follow transition, Popup buttons hover regardless
	if not is_transitioning or btn.get_parent().name != "VBoxContainer":
		btn.modulate = Color(1.2, 1.2, 1.2)

func _on_button_exit(btn: Control):
	if btn == hint_scroll and hint_used:
		btn.modulate = Color(0.3, 0.3, 0.3)
	else:
		btn.modulate = Color.WHITE

func _on_collect_pressed():
	print("Collected!")

# --- REDIRECT TO LEVEL 2 ---
func _on_next_button_pressed():
	GameManager.next_scene_path = "res://Assets/Scene/Zypheria/zypheria_lvl_2.tscn"
	get_tree().change_scene_to_file("res://Assets/Scene/Zypheria/loading_screen.tscn")

func _on_cancel_button_pressed():
	start_new_game()
