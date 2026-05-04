extends Node2D

var current_q = 0
var correct_answers = 0 
var growth_stage = 0 
var current_mission = 1 

var time_left = 120.0 
var timer_active = false
var game_started = false

# UI References
@onready var win_popup = $UserInterface/BlackBG
@onready var popup_holder = $UserInterface/BlackBG/PopupHolder
@onready var lose_popup = $UserInterface/ColorRect 
@onready var lose_holder = $UserInterface/ColorRect/Over
@onready var hourglass_anim = $UserInterface/ColorRect/Over/Hourglass 

@onready var sfx_correct = $SfxCorrect
@onready var sfx_wrong = $SfxWrong
@onready var mission_label = $UserInterface/Control/ObjectiveHolder/VBoxContainer/MissionText

var questions = [
	{"q": "What part of the plant grows underground?", "options": ["Roots", "Leaves", "Flowers"], "answer": "Roots", "clue": "It anchors the plant!"},
	{"q": "What do plants release for us to breathe?", "options": ["Oxygen", "Carbon", "Methane"], "answer": "Oxygen", "clue": "We need this 'O' gas!"},
	{"q": "What do plants need from the sun?", "options": ["Light", "Heat", "Shadows"], "answer": "Light", "clue": "It helps them grow!"},
	{"q": "Which part of the plant makes food?", "options": ["Leaves", "Stem", "Petals"], "answer": "Leaves", "clue": "They are usually flat and green!"},
	{"q": "What do plants soak up from the soil?", "options": ["Water", "Air", "Sunlight"], "answer": "Water", "clue": "It falls from the rain!"},
	{"q": "What is the green stuff in leaves called?", "options": ["Chlorophyll", "Sap", "Sugar"], "answer": "Chlorophyll", "clue": "Starts with 'Chlo'!"},
	{"q": "What do plants grow from?", "options": ["Seeds", "Rocks", "Sand"], "answer": "Seeds", "clue": "You plant these in the dirt!"},
	{"q": "Which part attracts bees and butterflies?", "options": ["Flowers", "Thorns", "Roots"], "answer": "Flowers", "clue": "They have colorful petals!"},
	{"q": "What is the main stem of a tree called?", "options": ["Trunk", "Branch", "Twig"], "answer": "Trunk", "clue": "Like an elephant's nose!"},
	{"q": "Plants need this space to grow their roots:", "options": ["Soil", "Plastic", "Glass"], "answer": "Soil", "clue": "Another word for dirt!"},
	{"q": "What do we call a scientist who studies plants?", "options": ["Botanist", "Pilot", "Chef"], "answer": "Botanist", "clue": "Named after 'Botany'!"},
	{"q": "Which of these is a vegetable?", "options": ["Carrot", "Apple", "Grape"], "answer": "Carrot", "clue": "It's orange and crunchy!"},
	{"q": "What do plants need to drink?", "options": ["Water", "Soda", "Milk"], "answer": "Water", "clue": "H2O!"},
	{"q": "What part of the plant holds it up?", "options": ["Stem", "Petals", "Fruit"], "answer": "Stem", "clue": "It's like the plant's backbone!"},
	{"q": "What do we call the colorful part of a plant?", "options": ["Flower", "Root", "Dirt"], "answer": "Flower", "clue": "Red, blue, or yellow petals!"}
]

var failed_questions = []

func _ready():
	randomize() 
	questions.shuffle()
	
	$UserInterface/Control/QuestionBox.hide()
	$UserInterface/Control/TimerContainer.hide()
	win_popup.hide() 
	lose_popup.hide() 
	
	mission_label.text = "Become a Master Gardener! Answer questions correctly to help your seeds grow into beautiful plants.\n\nBe quick—you only have 1 minute and 20 seconds! Can you turn the Grove into a blooming paradise?"
	
	$Sprinkler.frame = 0
	$Plant1.frame = 0
	$Plant2.frame = 0
	$UserInterface/Control/ProgressBar.frame = 0
	
	start_entry_countdown()

func start_entry_countdown():
	var countdown = 5
	$UserInterface/Control/QuestionBox.show()
	while countdown > 0:
		$UserInterface/Control/QuestionBox/QuestionText.text = "Game starting in... " + str(countdown)
		await get_tree().create_timer(1.0).timeout
		countdown -= 1
	game_started = true
	timer_active = true 
	$UserInterface/Control/TimerContainer.show()
	load_question()

func _process(delta):
	if timer_active and game_started:
		time_left -= delta
		var mins = int(time_left) / 60
		var secs = int(time_left) % 60
		$UserInterface/Control/TimerContainer/TimeLabel.text = str(mins) + ":" + str(secs).pad_zeros(2)
		if time_left <= 0:
			time_left = 0
			timer_active = false
			game_over_lose()

func load_question():
	var data = questions[current_q]
	var choices = data["options"].duplicate()
	choices.shuffle() 
	
	if data in failed_questions:
		$UserInterface/Control/QuestionBox/QuestionText.text = data["q"] + "\n(Hint: " + data["clue"] + ")"
	else:
		$UserInterface/Control/QuestionBox/QuestionText.text = data["q"]
		
	$UserInterface/Control/Choice1/Label.text = choices[0]
	$UserInterface/Control/Choice2/Label.text = choices[1]
	$UserInterface/Control/Choice3/Label.text = choices[2]
	$UserInterface/Control/QuestionBox.show()

func check_answer(idx):
	if not game_started or not timer_active: return 
	var selected_answer = get_node("UserInterface/Control/Choice" + str(idx + 1) + "/Label").text
	
	if selected_answer == questions[current_q]["answer"]:
		sfx_correct.play()
		correct_answers += 1
		grow_garden()
		
		if correct_answers >= 6:
			show_win_popup()
		else:
			await get_tree().create_timer(0.5).timeout
			current_q += 1
			check_list_bounds()
			load_question()
	else:
		handle_incorrect_flow()

func handle_incorrect_flow():
	sfx_wrong.play()
	var wrong_q = questions[current_q]
	
	if not wrong_q in failed_questions:
		failed_questions.append(wrong_q)
	
	var tween = create_tween()
	tween.tween_property($UserInterface/Control/QuestionBox, "modulate", Color.RED, 0.1)
	tween.chain().tween_property($UserInterface/Control/QuestionBox, "modulate", Color.WHITE, 0.1)
	
	await get_tree().create_timer(0.8).timeout
	
	questions.remove_at(current_q)
	questions.push_back(wrong_q)
	
	check_list_bounds()
	load_question()

func check_list_bounds():
	if current_q >= questions.size():
		current_q = 0

func grow_garden():
	growth_stage += 1
	$Sprinkler.frame = 1 
	$UserInterface/Control/ProgressBar.frame = correct_answers
	
	var target_plant = $Plant1 if current_mission == 1 else $Plant2
	
	var tween = create_tween()
	target_plant.frame = growth_stage
	target_plant.scale = Vector2(0.8, 0.8)
	tween.tween_property(target_plant, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(target_plant, "scale", Vector2(1.0, 1.0), 0.1)
	
	if growth_stage == 3 and current_mission == 1:
		complete_mission(2)
		
	await get_tree().create_timer(1.0).timeout
	$Sprinkler.frame = 0

func complete_mission(next_mission_num):
	await get_tree().create_timer(0.5).timeout
	growth_stage = 0
	current_mission = next_mission_num

func show_win_popup():
	game_started = false
	timer_active = false
	$UserInterface/Control/QuestionBox.hide()
	win_popup.show()
	popup_holder.scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(popup_holder, "scale", Vector2(0.4, 0.4), 0.5).set_trans(Tween.TRANS_BACK)

func game_over_lose():
	game_started = false
	timer_active = false
	$UserInterface/Control/QuestionBox.hide()
	
	lose_popup.show()
	hourglass_anim.play("default") 
	
	lose_holder.scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(lose_holder, "scale", Vector2(0.8, 0.8), 0.5).set_trans(Tween.TRANS_BACK)

# --- Button Signals Integrated with GameManager ---

func _on_back_pressed(): 
	# Return to map via loading screen
	GameManager.load_scene("res://Assets/Scene/science.scn") 

func _on_next_pressed(): 
	# Go to next minigame via loading screen
	GameManager.load_scene("res://Assets/Scene/Minigame2.tscn") 

func _on_try_pressed(): 
	# Reload current level via loading screen
	GameManager.load_scene(get_tree().current_scene.scene_file_path) 

func _on_texture_button_pressed(): 
	# Return to map via loading screen from lose popup
	GameManager.load_scene("res://Assets/Scene/science.scn") 

func _on_choice_1_pressed(): check_answer(0)
func _on_choice_2_pressed(): check_answer(1)
func _on_choice_3_pressed(): check_answer(2)
