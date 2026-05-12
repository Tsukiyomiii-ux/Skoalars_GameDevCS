extends Node2D

# Save File Path
const SAVE_PATH = "user://continents_study_progress.cfg"

# Node references
@onready var first_popup = $CanvasLayer/FirstPopUp
@onready var next_btn = $CanvasLayer/HBoxContainer/GridContainer/NextBtn
@onready var back_btn = $CanvasLayer/HBoxContainer/GridContainer/BackBtn
@onready var left_page = $CanvasLayer/HBoxContainer2/LeftPage
@onready var right_page_image = $"CanvasLayer/HBoxContainer2/RightPage-IMAGE"
@onready var done_btn = $CanvasLayer/DoneBtn
@onready var cancel_btn = $CanvasLayer/CancelBtn
@onready var book_content_container = $CanvasLayer/HBoxContainer2
@onready var reflection_container = $CanvasLayer/HBoxContainer3

# Reflection Input Nodes
@onready var answer_1 = $CanvasLayer/HBoxContainer3/Question1_LeftPage/Answer1
@onready var answer_2 = $CanvasLayer/HBoxContainer3/Question2_RightPage/Answer2

var current_spread = -1 

var spreads = [
	{
		"left_text": "[b]Imagine the Earth is like a giant puzzle.[/b]\n\nMost of the puzzle is blue water (the oceans), but there are seven big 'puzzle pieces' of land.\n\n[b]Let's meet them![/b]",
		"image_path": "res://Assets/StudySession/CONTINENTS/worldPuzzle.png" 
	},
	{
		"left_text": "[b]1. Asia (The Giant)[/b]\nAsia is the biggest continent of all! More people live here than anywhere else in the world.\n\n• [b]Cool Fact:[/b] It is home to Mount Everest, the highest mountain on Earth.\n• [b]Animals:[/b] Giant pandas, tigers, and elephants.",
		"image_path": "res://Assets/StudySession/CONTINENTS/ASIA.png"
	},
	{
		"left_text": "[b]2. Africa (The Sunny Safari)[/b]\nAfrica is the second-largest continent and is famous for its amazing wildlife and hot deserts.\n\n• [b]Cool Fact:[/b] The Sahara Desert is here—it's so big it’s almost the size of the United States!\n• [b]Animals:[/b] Lions, giraffes, zebras, and hippos.",
		"image_path": "res://Assets/StudySession/CONTINENTS/AFRICA.png"
	},
	{
		"left_text": "[b]3. North America (Our Home)[/b]\nThis is the continent where countries like the USA, Canada, and Mexico are located.\n\n• [b]Cool Fact:[/b] It has every kind of weather—from freezing ice in Greenland to hot tropical beaches in Panama.\n• [b]Animals:[/b] Bald eagles, brown bears, and moose.",
		"image_path": "res://Assets/StudySession/CONTINENTS/NORTH AMERICA.png"
	},
	{
		"left_text": "[b]4. South America (The Rain Forest)[/b]\nSouth America is famous for being very green and lush.\n\n• [b]Cool Fact:[/b] It has the Amazon Rainforest, which is like the 'lungs of the planet' because it produces so much oxygen.\n• [b]Animals:[/b] Toucans, jaguars, and sloths.",
		"image_path": "res://Assets/StudySession/CONTINENTS/SOUTH AMERICA.png"
	},
	{
		"left_text": "[b]5. Antarctica (The Ice Box)[/b]\nAntarctica is at the very bottom of the world. It is the coldest, windiest, and driest place on Earth.\n\n• [b]Cool Fact:[/b] No people live here permanently; only scientists visit to study the ice.\n• [b]Animals:[/b] Penguins and seals (but no polar bears—they live at the North Pole!).",
		"image_path": "res://Assets/StudySession/CONTINENTS/ANTARCTICA.png"
	},
	{
		"left_text": "[b]6. Europe (The Land of Castles)[/b]\nEurope is a smaller continent, but it has many different countries packed close together.\n\n• [b]Cool Fact:[/b] It is famous for old history, beautiful cities, and many ancient castles.\n• [b]Animals:[/b] Red foxes, wolves, and reindeer.",
		"image_path": "res://Assets/StudySession/CONTINENTS/EUROPE.png"
	},
	{
		"left_text": "[b]7. Australia (The Island Continent)[/b]\nAustralia is the smallest continent and is also a single country! It is completely surrounded by water.\n\n• [b]Cool Fact:[/b] It has the Great Barrier Reef, the largest coral reef system in the world.\n• [b]Animals:[/b] Kangaroos, koalas, and platypuses.",
		"image_path": "res://Assets/StudySession/CONTINENTS/AUSTRALIA (2).png"
	},
	{
		"is_reflection": true,
		"left_text": "", 
		"image_path": ""
	}
]

func _ready():
	AudioManager.play_music(preload("res://Assets/Audio/StudySessionBG.wav"))
	# 1. Load saved answer text
	load_answers()
	
	# 2. Force start at the intro popup
	current_spread = -1
	
	# Signal Connections
	next_btn.pressed.connect(_on_next_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	done_btn.pressed.connect(_on_done_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	
	# Hover Effect Setup
	var all_buttons = [next_btn, back_btn, done_btn, cancel_btn]
	for btn in all_buttons:
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))
		btn.pivot_offset = btn.size / 2 
	
	# Word count and auto-save
	answer_1.text = GameManager.get_study_answer("continents", "answer1")
	answer_2.text = GameManager.get_study_answer("continents", "answer2")
	answer_1.text_changed.connect(_on_answer_changed)
	answer_2.text_changed.connect(_on_answer_changed)

	# Update UI to initial state
	update_pages()

# --- Navigation Logic ---

func update_pages():
	if current_spread == -1:
		# Initial Popup State
		first_popup.visible = true
		book_content_container.visible = false
		reflection_container.visible = false
		
		next_btn.visible = true 
		back_btn.visible = false
		done_btn.visible = false
	else:
		# Lesson / Reflection State
		first_popup.visible = false
		var data = spreads[current_spread]
		
		if data.get("is_reflection", false):
			book_content_container.visible = false
			reflection_container.visible = true
			next_btn.visible = false
		else:
			book_content_container.visible = true
			reflection_container.visible = false
			next_btn.visible = true
			
			left_page.text = data["left_text"]
			if data["image_path"] != "":
				right_page_image.texture = load(data["image_path"])

		# Show back button if we are at the first lesson page or further
		back_btn.visible = current_spread >= 0
		_check_reflection()

func _on_next_pressed():
	current_spread += 1
	update_pages()

func _on_back_pressed():
	current_spread -= 1
	update_pages()

# --- Saving & Persistence ---

func _on_answer_changed():
	GameManager.save_study_answer("continents", "answer1", answer_1.text)
	GameManager.save_study_answer("continents", "answer2", answer_2.text)
	_check_reflection()

func save_answers():
	var config = ConfigFile.new()
	config.set_value("ContinentData", "answer_1", answer_1.text)
	config.set_value("ContinentData", "answer_2", answer_2.text)
	config.save(SAVE_PATH)

func load_answers():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		answer_1.text = config.get_value("ContinentData", "answer_1", "")
		answer_2.text = config.get_value("ContinentData", "answer_2", "")

# --- Button Logic ---

func _check_reflection():
	if current_spread == spreads.size() - 1:
		var words1 = answer_1.text.split(" ", false).size()
		var words2 = answer_2.text.split(" ", false).size()
		done_btn.visible = (words1 >= 10 and words2 >= 10)
	else:
		done_btn.visible = false

func _on_done_pressed():
	save_answers()
	GameManager.add_diamonds(1)
	GameManager.complete_study_topic("geography",'continents')
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/geography_study_lesson.tscn")

func _on_cancel_pressed():
	save_answers()
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/geography_study_lesson.tscn")

# --- Hover Animations ---
func _on_button_hover(btn):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)

func _on_button_unhover(btn):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
