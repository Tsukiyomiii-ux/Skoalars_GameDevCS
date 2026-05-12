extends Node2D

# Save File Path
const SAVE_PATH = "user://geography_progress.cfg"

# Navigation and Display References
@onready var next_btn = $CanvasLayer/HBoxContainer/GridContainer/NextBtn
@onready var back_btn = $CanvasLayer/HBoxContainer/GridContainer/BackBtn
@onready var left_display = $CanvasLayer/HBoxContainer2/LeftFlag
@onready var right_display = $CanvasLayer/HBoxContainer2/RightFlag

# Exit Buttons
@onready var done_btn = $CanvasLayer/DoneBtn
@onready var cancel_btn = $CanvasLayer/CancelBtn

# Question Containers and Input Fields
@onready var question_container = $CanvasLayer/HBoxContainer3
@onready var answer_1 = $CanvasLayer/HBoxContainer3/Question1_LeftPage/Answer1
@onready var answer_2 = $CanvasLayer/HBoxContainer3/Question2_RightPage/Answer2

# This will ALWAYS start at 0 when the scene is loaded
var current_spread = 0 

var flag_spreads = [
	{"left": preload("res://Assets/StudySession/Flags/flags1.png"), "right": preload("res://Assets/StudySession/Flags/flags2.png")},
	{"left": preload("res://Assets/StudySession/Flags/flags3.png"), "right": preload("res://Assets/StudySession/Flags/flags4.png")},
	{"left": preload("res://Assets/StudySession/Flags/flags5.png"), "right": preload("res://Assets/StudySession/Flags/flags6.png")},
	{"left": preload("res://Assets/StudySession/Flags/flags7.png"), "right": preload("res://Assets/StudySession/Flags/flags8.png")},
	{"left": preload("res://Assets/StudySession/Flags/flags9.png"), "right": preload("res://Assets/StudySession/Flags/flags10.png")},
	{"left": preload("res://Assets/StudySession/Flags/flags11.png"), "right": preload("res://Assets/StudySession/Flags/flags12.png")},
	{"left": preload("res://Assets/StudySession/Flags/flags13.png"), "right": preload("res://Assets/StudySession/Flags/flags14.png")},
	{"left": preload("res://Assets/StudySession/Flags/flags15.png"), "right": preload("res://Assets/StudySession/Flags/flags16.png")}
]

func _ready():
	AudioManager.play_music(preload("res://Assets/Audio/StudySessionBG.wav"))
	# Connect Signals
	next_btn.pressed.connect(_on_next_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	done_btn.pressed.connect(_on_done_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	
	answer_1.text = GameManager.get_study_answer("flags", "answer1")
	answer_2.text = GameManager.get_study_answer("flags", "answer2")
	
	var all_btns = [next_btn, back_btn, done_btn, cancel_btn]
	for btn in all_btns:
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))
		btn.pivot_offset = btn.size / 2
	
	# 1. LOAD THE ANSWERS ONLY
	load_answers()
	
	# 2. RESET PAGE TO 0
	current_spread = 0
	
	# 3. UPDATE UI
	update_flag_pages()

func _on_next_pressed():
	if current_spread < flag_spreads.size() - 1:
		current_spread += 1
		update_flag_pages()

func _on_back_pressed():
	if current_spread > 0:
		current_spread -= 1
		update_flag_pages()

func _on_done_pressed():
	save_answers()
	GameManager.add_diamonds(1)
	GameManager.complete_study_topic("geography","flags")
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/geography_study_lesson.tscn")

func _on_cancel_pressed():
	save_answers()
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/geography_study_lesson.tscn")

func update_flag_pages():
	var is_last_page = (current_spread == flag_spreads.size() - 1)
	
	left_display.visible = !is_last_page
	right_display.visible = !is_last_page
	
	if !is_last_page:
		var data = flag_spreads[current_spread]
		left_display.texture = data["left"]
		right_display.texture = data["right"]
	
	question_container.visible = is_last_page
	back_btn.visible = current_spread > 0
	next_btn.visible = !is_last_page
	
	validate_done_button()

func _on_answer_text_changed():
		GameManager.save_study_answer("flags", "answer1", answer_1.text)
		GameManager.save_study_answer("flags", "answer2", answer_2.text)

func validate_done_button():
	var is_last_page = (current_spread == flag_spreads.size() - 1)
	if is_last_page:
		var count1 = get_word_count(answer_1.text)
		var count2 = get_word_count(answer_2.text)
		done_btn.visible = (count1 >= 10 and count2 >= 10)
	else:
		done_btn.visible = false

func get_word_count(input_text: String) -> int:
	var words = input_text.split(" ", false)
	return words.size()

# --- MODIFIED SAVE/LOAD: ONLY FOR TEXT ---

func save_answers():
	var config = ConfigFile.new()
	# We save the text, but we DON'T save current_spread
	config.set_value("Data", "answer_1", answer_1.text)
	config.set_value("Data", "answer_2", answer_2.text)
	config.save(SAVE_PATH)

func load_answers():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err == OK:
		# Put the text back, but keep the current_spread at 0
		answer_1.text = config.get_value("Data", "answer_1", "")
		answer_2.text = config.get_value("Data", "answer_2", "")

# --- Visual Effects ---
func _on_button_hover(btn):
	var t = create_tween()
	t.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)

func _on_button_unhover(btn):
	var t = create_tween()
	t.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
