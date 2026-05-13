extends Node2D

# Save File Path
const SAVE_PATH = "user://tectonic_study_progress.cfg"

# Existing Node references
@onready var next_btn = $CanvasLayer/HBoxContainer/GridContainer/NextBtn
@onready var back_btn = $CanvasLayer/HBoxContainer/GridContainer/BackBtn
@onready var left_page = $CanvasLayer/HBoxContainer2/LeftPage
@onready var right_page = $CanvasLayer/HBoxContainer2/RightPage

# Exit references
@onready var done_btn = $CanvasLayer/DoneBtn
@onready var cancel_btn = $CanvasLayer/CancelBtn

# New references for the reflection questions
@onready var question_container = $CanvasLayer/HBoxContainer3
@onready var answer_1 = $CanvasLayer/HBoxContainer3/Question1_LeftPage/Answer1
@onready var answer_2 = $CanvasLayer/HBoxContainer3/Question2_RightPage/Answer2

var current_spread = 0 
const MIN_WORDS = 10

var spreads = [
	{
		"left_text": "[center][b]The Core Concept[/b][/center]\n\n[b]The Earth is a Puzzle[/b]\nImagine the Earth's outer shell isn't one solid piece, but a giant jigsaw puzzle. These pieces are called [color=brown]tectonic plates[/color].",
		"right_text": "They aren't sitting still; they are constantly floating on a layer of hot, flowing rock underneath them.\n\n[b]3 Ways the \"Puzzle Pieces\" Move[/b]\nThe most interesting parts of geography happen at the boundaries where these plates meet."
	},
	{
		"left_text": "[b]1. Divergent (Moving Apart)[/b]\n\n[i]What happens:[/i] Plates pull away from each other, and magma rises to create new land.",
		"right_text": "[i]Real-world example:[/i]\nThe Mid-Atlantic Ridge, where the ocean floor is literally growing, pushing the Americas away from Europe and Africa."
	},
	{
		"left_text": "[b]2. Convergent (Crashing Together)[/b]\n\n[i]What happens:[/i] Two plates collide. If one is thinner, it slides underneath (creating volcanoes). If they are both thick, they crumple upward.",
		"right_text": "[i]Real-world example:[/i]\nThe Himalayas. The plate carrying India is crashing into Asia, pushing the land up into the highest mountains in the world."
	},
	{
		"left_text": "[b]3. Transform (Sliding Past)[/b]\n\n[i]What happens:[/i] Plates grind past each other sideways. They often get stuck, and when they finally \"snapping\" loose, they release energy.",
		"right_text": "[i]Real-world example:[/i]\nThe San Andreas Fault in California, which is famous for causing frequent earthquakes."
	},
	{
		"left_text": "[center][b]Why this matters[/b][/center]\n\n[b]The Past:[/b] It explains how the 7 continents used to be one giant \"supercontinent\" called [b]Pangea[/b] before they drifted apart.",
		"right_text": "[b]The Present:[/b] Tells us why some countries have earthquakes while others don't.\n\n[b]The Future:[/b] The continents are still moving! The map will look different in millions of years."
	}
]

func _ready():
	AudioManager.play_music(preload("res://Assets/Audio/StudySessionBG.wav"))
	# Connect Navigation signals
	next_btn.pressed.connect(_on_next_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	
	# Connect Exit signals
	done_btn.pressed.connect(_on_done_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	
	# Connect Answer signals to check word count live

	# Setup all buttons for hover effects
	var all_btns = [next_btn, back_btn, done_btn, cancel_btn]
	for btn in all_btns:
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))
		btn.pivot_offset = btn.size / 2
	
	answer_1.text = GameManager.get_study_answer("tectonic", "answer1")
	answer_2.text = GameManager.get_study_answer("tectonic", "answer2")
	answer_1.text_changed.connect(_on_answer_changed)
	answer_2.text_changed.connect(_on_answer_changed)
	
	# 2. Reset page to the beginning
	current_spread = 0
	
	# 3. Initial UI update
	update_pages()

# --- Navigation Logic ---
func _on_next_pressed():
	if current_spread < spreads.size():
		current_spread += 1
		update_pages()

func _on_back_pressed():
	if current_spread > 0:
		current_spread -= 1
		update_pages()

# --- Validation Logic ---
func _on_answer_changed():
	GameManager.save_study_answer("tectonic", "answer1", answer_1.text)
	GameManager.save_study_answer("tectonic", "answer2", answer_2.text)
	_check_word_count()

func _check_word_count():
	var words1 = answer_1.text.split(" ", false)
	var words2 = answer_2.text.split(" ", false)
	
	# Done button only appears if both answers meet the 10-word minimum
	if words1.size() >= MIN_WORDS and words2.size() >= MIN_WORDS:
		done_btn.visible = true
	else:
		done_btn.visible = false

func update_pages():
	# Check if we are on the final "Reflection" spread
	if current_spread == spreads.size():
		# Show reflection inputs, hide standard text pages
		$CanvasLayer/HBoxContainer2.visible = false
		question_container.visible = true
		
		next_btn.visible = false
		back_btn.visible = true
		_check_word_count() # Run check to see if Done should be visible
	else:
		# Show standard reading pages
		$CanvasLayer/HBoxContainer2.visible = true
		question_container.visible = false
		
		var data = spreads[current_spread]
		left_page.text = data["left_text"]
		right_page.text = data["right_text"]
		
		back_btn.visible = current_spread > 0
		next_btn.visible = true
		done_btn.visible = false

# --- PERSISTENCE SYSTEM ---

func save_answers():
	var config = ConfigFile.new()
	config.set_value("TectonicData", "answer_1", answer_1.text)
	config.set_value("TectonicData", "answer_2", answer_2.text)
	config.save(SAVE_PATH)

func load_answers():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err == OK:
		answer_1.text = config.get_value("TectonicData", "answer_1", "")
		answer_2.text = config.get_value("TectonicData", "answer_2", "")

# --- Exit Logic ---
func _on_done_pressed():
	print("🔍 capitals in completed_topics: ", GameManager.completed_topics.has("capitals"))
	print("🔍 diamonds before: ", GameManager.diamonds)
	if not GameManager.completed_topics.has("tectonic"):
		GameManager.add_diamonds(1)
	GameManager.complete_study_topic("geography","tectonic")
	print("🔍 diamonds after: ", GameManager.diamonds)
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/geography_study_lesson.tscn")

func _on_cancel_pressed():
	save_answers()
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/geography_study_lesson.tscn")

# --- Visual Button Feedback ---
func _on_button_hover(btn):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_QUAD)

func _on_button_unhover(btn):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD)
