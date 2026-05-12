extends Node2D

# Save File Path
const SAVE_PATH = "user://geography_study_progress.cfg"

# Navigation and Page References
@onready var next_btn = $CanvasLayer/HBoxContainer/GridContainer/NextBtn
@onready var back_btn = $CanvasLayer/HBoxContainer/GridContainer/BackBtn
@onready var left_page = $CanvasLayer/HBoxContainer2/LeftPage
@onready var right_page = $CanvasLayer/HBoxContainer2/RightPage

# Exit Buttons
@onready var done_btn = $CanvasLayer/DoneBtn
@onready var cancel_btn = $CanvasLayer/CancelBtn

# Question References
@onready var question_container = $CanvasLayer/HBoxContainer3
@onready var answer_1 = $CanvasLayer/HBoxContainer3/Question1_LeftPage/Answer1
@onready var answer_2 = $CanvasLayer/HBoxContainer3/Question2_RightPage/Answer2

# This will ALWAYS start at 0 when the scene is loaded
var current_spread = 0 

var spreads = [
	{
		"left_text": "Argentina: Land of the Tango and the Andes.\n\nCosta Rica: Lush \"Pura Vida\" rainforest paradise.\n\nEcuador: Named for the Equator; home to the Galápagos.\n\nEgypt: Home of the Great Pyramids and the Nile.\n\nGuatemala: Heart of the ancient Maya world.",
		"right_text": "[center][b]CAPITAL CITY[/b][/center]\nArgentina: Buenos Aires\n\nCosta Rica: San José\n\nEcuador: Quito\n\nEgypt: Cairo\n\nGuatemala: Guatemala City"
	},
	{
		"left_text": "Italy: Land of pizza, pasta, and the Colosseum.\n\nJapan: Land of the rising sun and bullet trains.\n\nMadagascar: The island of lemurs and baobab trees.\n\nPhilippines: Archipelago of 7,000 islands and white beaches.\n\nSamoa: The volcanic heart of Polynesian culture.",
		"right_text": "[center][b]CAPITAL CITY[/b][/center]\nItaly: Rome\n\nJapan: Tokyo\n\nMadagascar: Antananarivo\n\nPhilippines: Manila\n\nSamoa: Apia"
	},
	{
		"left_text": "Spain: Famous for flamenco dancing and tapas.\n\nUnited States: Home of Hollywood and the Statue of Liberty.\n\nAustralia: The \"Land Down Under\" with kangaroos.\n\nBrazil: Giant rainforests and the Christ the Redeemer statue.\n\nCanada: Land of maple syrup, hockey, and snowy mountains.",
		"right_text": "[center][b]CAPITAL CITY[/b][/center]\nSpain: Madrid\n\nUnited States of America: Washington, D.C.\n\nAustralia: Canberra\n\nBrazil: Brasília\n\nCanada: Ottawa"
	},
	{
		"left_text": "France: Iconic home of the Eiffel Tower and pastries.\n\nGreece: The cradle of history and the Parthenon.\n\nKenya: Famous for wild African safaris and the Savannah.\n\nMexico: Ancient Mayan ruins and world-famous tacos.\n\nSouth Korea: The global hub of K-Pop and tech.",
		"right_text": "[center][b]CAPITAL CITY[/b][/center]\nFrance: Paris\n\nGreece: Athens\n\nKenya: Nairobi\n\nMexico: Mexico City\n\nSouth Korea: Seoul"
	}
]

func _ready():
	# Connect Button Signals
	next_btn.pressed.connect(_on_next_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	done_btn.pressed.connect(_on_done_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	
	# Connect Input Signals
	answer_1.text = GameManager.get_study_answer("capitals", "answer1")
	answer_2.text = GameManager.get_study_answer("capitals", "answer2")
	
	# Setup Button Hovers
	var all_btns = [next_btn, back_btn, done_btn, cancel_btn]
	for btn in all_btns:
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))
		btn.pivot_offset = btn.size / 2
	
	# 1. Load the answers from the previous session
	load_answers()
	
	# 2. Ensure we start on the first page
	current_spread = 0
	
	# 3. Update the UI
	update_pages()

func update_pages():
	var is_question_page = (current_spread == spreads.size())
	
	left_page.visible = !is_question_page
	right_page.visible = !is_question_page
	question_container.visible = is_question_page
	
	if !is_question_page:
		var data = spreads[current_spread]
		left_page.text = data["left_text"]
		right_page.text = data["right_text"]
	
	back_btn.visible = current_spread > 0
	next_btn.visible = !is_question_page
	
	validate_done_button()

# --- NAVIGATION & VALIDATION ---

func _on_next_pressed():
	if current_spread < spreads.size():
		current_spread += 1
		update_pages()

func _on_back_pressed():
	if current_spread > 0:
		current_spread -= 1
		update_pages()

func validate_done_button():
	var is_question_page = (current_spread == spreads.size())
	if is_question_page:
		var t1 = get_word_count(answer_1.text)
		var t2 = get_word_count(answer_2.text)
		done_btn.visible = (t1 >= 10 and t2 >= 10)
	else:
		done_btn.visible = false

func get_word_count(input_text: String) -> int:
	var words = input_text.split(" ", false)
	return words.size()

func _on_answer_text_changed():
	GameManager.save_study_answer("capitals", "answer1", answer_1.text)
	GameManager.save_study_answer("capitals", "answer2", answer_2.text)

func _on_done_pressed():
	save_answers()
	GameManager.add_diamonds(1)
	GameManager.complete_study_topic("geography")
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/geography_study_lesson.tscn")

func _on_cancel_pressed():
	save_answers()
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/geography_study_lesson.tscn")

# --- SAVE/LOAD SYSTEM ---

func save_answers():
	var config = ConfigFile.new()
	# Save only the text data
	config.set_value("StudyData", "answer_1", answer_1.text)
	config.set_value("StudyData", "answer_2", answer_2.text)
	config.save(SAVE_PATH)

func load_answers():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err == OK:
		answer_1.text = config.get_value("StudyData", "answer_1", "")
		answer_2.text = config.get_value("StudyData", "answer_2", "")

# --- Visual Effects ---
func _on_button_hover(btn):
	var t = create_tween()
	t.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)

func _on_button_unhover(btn):
	var t = create_tween()
	t.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
