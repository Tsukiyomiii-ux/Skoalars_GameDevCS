extends Node2D

# 1. QUIZ UI PATHS
@onready var question_label = $"CanvasLayer/SCROLL,CLOUDS, MISSION/QuestionLabel"
@onready var choice_btns = [
	$"CanvasLayer/SCROLL,CLOUDS, MISSION/Choice1",
	$"CanvasLayer/SCROLL,CLOUDS, MISSION/Choice2",
	$"CanvasLayer/SCROLL,CLOUDS, MISSION/Choice3"
]
@onready var progression_bar = $CanvasLayer/ProgressBar
@onready var score_label = $CanvasLayer/ScoreLabel

# 2. POPUP & VIDEO UI PATHS
@onready var popup_layer = $PopupLayer
@onready var win_popup = $PopupLayer/WinPopup
@onready var lose_popup = $PopupLayer/LosePopup
@onready var world_map_popup = $CanvasLayer/WorldMapPopup
@onready var map_timer_label = $CanvasLayer/WorldMapPopup/MapTimerLabel
@onready var hint_button = $CanvasLayer/HintScroll
@onready var hint_bg_dim = $CanvasLayer/ColorRect 
@onready var rescue_video = $CanvasLayer/RescueVideo

# Win Buttons
@onready var collect_button = $PopupLayer/WinPopup/MainFrame/CollectButton
@onready var rescue_button = $PopupLayer/WinPopup/BottomButtons1/RescueButton
@onready var win_cancel_button = $PopupLayer/WinPopup/BottomButtons1/CancelButton

# Lose Buttons
@onready var quit_button = $PopupLayer/LosePopup/GameOverFrame/BottomButtons2/QuitButton
@onready var try_again_button = $PopupLayer/LosePopup/GameOverFrame/BottomButtons2/TryAgainButton

# 3. SOUND NODES
@onready var correct_sound = $CorrectSound
@onready var wrong_sound = $WrongSound

# 4. TIMER UI
@onready var timer_progress_bar = $TimerProgressBar 
@onready var timer_label = $TimerLabel
@onready var game_timer = $Timer

# DATA
var all_questions = [
	{"q": "What is the capital of Argentina?", "a": "Buenos Aires"},
	{"q": "What is the capital of Costa Rica?", "a": "San José"},
	{"q": "What is the capital of Ecuador?", "a": "Quito"},
	{"q": "What is the capital of Egypt?", "a": "Cairo"},
	{"q": "What is the capital of Guatemala?", "a": "Guatemala City"},
	{"q": "What is the capital of Italy?", "a": "Rome"},
	{"q": "What is the capital of Japan?", "a": "Tokyo"},
	{"q": "What is the capital of Madagascar?", "a": "Antananarivo"},
	{"q": "What is the capital of Philippines?", "a": "Manila"},
	{"q": "What is the capital of Samoa?", "a": "Apia"},
	{"q": "What is the capital of Spain?", "a": "Madrid"},
	{"q": "What is the capital of United States?", "a": "Washington, D.C."},
	{"q": "What is the capital of Australia?", "a": "Canberra"},
	{"q": "What is the capital of Brazil?", "a": "Brasília"},
	{"q": "What is the capital of Canada?", "a": "Ottawa"},
	{"q": "What is the capital of France?", "a": "Paris"},
	{"q": "What is the capital of Greece?", "a": "Athens"},
	{"q": "What is the capital of Kenya?", "a": "Nairobi"},
	{"q": "What is the capital of Mexico?", "a": "Mexico City"},
	{"q": "What is the capital of South Korea?", "a": "Seoul"}
]

var session_questions = []
var score = 0
var target_score = 10
var is_transitioning = false
var hint_timer_active = false
var hint_time_left = 10.0

func _ready():
	randomize()
	all_questions.shuffle()
	session_questions = all_questions.slice(0, 10) 
	
	# Initial UI State
	popup_layer.show() 
	win_popup.hide()
	lose_popup.hide()
	world_map_popup.hide()
	hint_bg_dim.hide() 
	rescue_video.hide() 
	
	# Connect All Buttons to Hover Logic
	var all_ui_buttons = []
	all_ui_buttons.append_array(choice_btns)
	all_ui_buttons.append(hint_button)
	all_ui_buttons.append(collect_button)
	all_ui_buttons.append(rescue_button)
	all_ui_buttons.append(win_cancel_button)
	all_ui_buttons.append(quit_button)
	all_ui_buttons.append(try_again_button)
	
	for btn in all_ui_buttons:
		if btn:
			btn.mouse_entered.connect(self._on_button_hover.bind(btn))
			btn.mouse_exited.connect(self._on_button_exit.bind(btn))
	
	# Connect Choice Click Logic
	for btn in choice_btns:
		if btn:
			btn.pressed.connect(self._on_answer_selected.bind(btn))
			if btn.has_node("Label"):
				btn.get_node("Label").mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Connect Remaining Button Logic
	hint_button.pressed.connect(_on_hint_pressed)
	collect_button.pressed.connect(_on_collect_pressed)
	rescue_button.pressed.connect(_on_rescue_pressed) 
	win_cancel_button.pressed.connect(_on_try_again_pressed) 
	
	if quit_button: quit_button.pressed.connect(_on_quit_pressed)
	if try_again_button: try_again_button.pressed.connect(_on_try_again_pressed)
	
	rescue_video.finished.connect(_on_video_finished)
	game_timer.timeout.connect(_on_timer_timeout)
	game_timer.start(90.0) 
	
	update_ui_displays()
	load_question()

func _process(delta):
	if game_timer and !game_timer.is_stopped():
		var time_left = ceil(game_timer.time_left)
		timer_label.text = "%01d:%02d" % [int(time_left / 60), int(time_left) % 60]
		timer_progress_bar.value = game_timer.time_left
	
	if hint_timer_active:
		hint_time_left -= delta
		map_timer_label.text = "Closing in: " + str(ceil(hint_time_left))
		if hint_time_left <= 0:
			_hide_hint()

# --- HOVER LOGIC ---
func _on_button_hover(btn):
	if btn and not btn.disabled:
		# If it's a quiz button, block hover during transition animations
		if btn in choice_btns and is_transitioning:
			return
		# All other buttons (Popup/Hint) should hover freely
		btn.modulate = Color(0.112, 0.07, 0.48, 1.0) 

func _on_button_exit(btn):
	if btn and not btn.disabled:
		# If it's a quiz button, block exit reset during transition animations
		if btn in choice_btns and is_transitioning:
			return
		btn.modulate = Color.WHITE

# --- HINT LOGIC ---
func _on_hint_pressed():
	if hint_timer_active or hint_button.disabled: 
		return 
	
	world_map_popup.show()
	hint_bg_dim.show() 
	hint_time_left = 10.0
	hint_timer_active = true
	
	hint_button.disabled = true 
	hint_button.modulate = Color(0.5, 0.5, 0.5, 0.5) 

func _hide_hint():
	hint_timer_active = false
	world_map_popup.hide()
	hint_bg_dim.hide() 

# --- QUIZ LOGIC ---
func load_question():
	if score >= target_score:
		end_game(true)
		return

	is_transitioning = false
	var current_q = session_questions[0]
	question_label.text = current_q["q"] 
	
	var choices = [current_q["a"]]
	var pool = []
	for item in all_questions:
		if item["a"] != current_q["a"]: pool.append(item["a"])
	pool.shuffle()
	choices.append(pool[0])
	choices.append(pool[1])
	choices.shuffle()
	
	for i in range(3):
		var btn = choice_btns[i]
		var lbl = btn.get_node("Label")
		lbl.text = choices[i]
		btn.modulate = Color.WHITE 
		lbl.add_theme_color_override("font_color", Color.WHITE)
		btn.disabled = false
		btn.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_answer_selected(button):
	if is_transitioning: return
	is_transitioning = true
	
	var lbl = button.get_node("Label")
	var chosen_answer = lbl.text
	var current_q = session_questions.pop_front()
	
	if chosen_answer == current_q["a"]:
		score += 1
		correct_sound.play()
		button.modulate = Color.GREEN
		lbl.add_theme_color_override("font_color", Color.GREEN)
		update_ui_displays()
		await get_tree().create_timer(0.5).timeout
	else:
		wrong_sound.play()
		button.modulate = Color.RED
		lbl.add_theme_color_override("font_color", Color.RED)
		session_questions.push_back(current_q)
		await get_tree().create_timer(0.8).timeout
	
	load_question()

func update_ui_displays():
	progression_bar.value = score
	score_label.text = str(score) + "/" + str(target_score)

# --- END GAME LOGIC ---
func end_game(is_win: bool):
	game_timer.stop()
	hint_timer_active = false
	world_map_popup.hide()
	hint_bg_dim.hide() 
	
	# Reset transitioning to false so popup buttons can hover immediately
	is_transitioning = false
	popup_layer.show()
	
	if is_win:
		win_popup.show()
		lose_popup.hide()
	else:
		timer_label.text = "0:00"
		lose_popup.show()
		win_popup.hide()

	for btn in choice_btns:
		btn.disabled = true

# --- RESCUE VIDEO LOGIC ---
func _on_rescue_pressed():
	rescue_video.show()
	rescue_video.play()
	win_popup.hide()

func _on_video_finished():
	GameManager.next_scene_path = "res://Assets/Scene/MainIsland/mapSelector.tscn"
	GameManager.unlock_island("island_4")
	get_tree().change_scene_to_file("res://Assets/Scene/Zypheria/loading_screen.tscn")

func _on_timer_timeout(): end_game(false)
func _on_collect_pressed(): print("Collected!")
func _on_try_again_pressed(): get_tree().reload_current_scene()
func _on_quit_pressed(): get_tree().change_scene_to_file("res://Assets/Scene/Zypheria/zypheria.tscn")
