extends Node2D

var current_q = 0
var correct_answers = 0 
var growth_stage = 0 
var current_mission = 1 

var time_left = 80.0 
var timer_active = false
var game_started = false
var is_frozen: bool = false

# UI References
@onready var win_popup = $btn/BlackBG
@onready var popup_holder = $btn/BlackBG/PopupHolder
@onready var lose_popup = $btn/ColorRect 
@onready var lose_holder = $btn/ColorRect/Over
@onready var hourglass_anim = $btn/ColorRect/Over/Hourglass 

@onready var sfx_correct = $SfxCorrect
@onready var sfx_wrong = $SfxWrong
@onready var mission_label = $UserInterface/Control/ObjectiveHolder/VBoxContainer/MissionText
@onready var wand_button = $btn/WandHolder/Wand

var questions = [
	{"q": "What part of the plant lies below the soil that absorbs water and mineral from it?", "options": ["Trunk", "Roots", "Flowers"], "answer": "Flowers", "clue": "The underground anchor"},
	{"q": "What part of the plant anchors it firmly to the soil?", "options": ["Trunk", "Roots", "Fruits"], "answer": "Roots", "clue": "They hold the plant in place like feet"},
	{"q": "What part of the plant produces growth hormones?", "options": ["Leaves", "Stem", "Roots"], "answer": "Roots", "clue": "The hidden part below the dirt."},
	{"q": "What part of the plant supports the leaves and conducts water and minerals?", "options": ["Stem", "Branch", "Log"], "answer": "Stem", "clue": "The plant's backbone or main pillar."},
	{"q": "What part of the plant transports food, water, and minerals to all parts of the plant body?", "options": ["Bramch", "Roots", "Stem"], "answer": "Stem", "clue": "It acts like a straw or elevator for nutrients."},
	{"q": "What part of the plant stores food mainly in the form of starch?", "options": ["Leaves", "Stem", "Flowers"], "answer": "Stem", "clue": "The long, central part that grows upward."},
	{"q": "The primary site of photosynthesis in most plants.", "options": ["Flowers", "Leaves", "Roots"], "answer": "Leaves", "clue": "The plant's kitchen or solar panels"},
	{"q": "What part of the plant is attached to the stem that makes food for the plant?", "options": ["Trunk", "Branch", "Leaves"], "answer": "Leaves", "clue": "The flat, green parts."},
	{"q": "What part of the plant helps in evaporation from the aerial parts of the plant by transpiration?", "options": ["Flowers", "Trunk", "Leaves"], "answer": "Leaves", "clue": "They breathe out water vapor."},
	{"q": "The reproductive part of the flowering plant", "options": ["Fruits", "Roots", "Flower"], "answer": "Flower", "clue": "The prettiest part that smells nice"},
	{"q": "What part of the plant is the most colorful and attractive?", "options": ["Leaves", "Flower", "Roots"], "answer": "Flower", "clue": "Where the seeds begin to form.!"},
	{"q": "What part of the plant stimulates pollination?", "options": ["Flower", "Leaves", "Trunk"], "answer": "Flower", "clue": "What bees and butterflies visit most."},
	{"q": "The seed-bearing structure in flowering plants.", "options": ["Stem", "Petals", "Fruit"], "answer": "Fruits", "clue": "The fleshy part we often like to eat."},
	{"q": "What part of the plant protects the growing seeds?", "options": ["Fruits", "Roots", "Leaves"], "answer": "Fruits", "clue": "Something animals eat and carry away."},
	{"q": "They are organisms that creates their own food.", "options": ["Primary", "Secondary", "Producers"], "answer": "Producers", "clue": "Like plants; they produce energy."},
	{"q": "They are organisms that feed directly on producers.", "options": ["Primary", "Secondary", "Producers"], "answer": "Primary", "clue": "The first ones to eat; usually herbivores."},
	{"q": "They are organisms that eat primary consumers for energy.", "options": ["Tertiary", "Secondary", "Decomposer"], "answer": "Secondary", "clue": "The second level of eaters; meat-eaters."},
	{"q": "They are organisms that are carnivores or omnivores that occupy the fourth trophic level.", "options": ["Producers", "Tertiary", "Primary"], "answer": "Tertiary", "clue": "Top-level hunters; the third type of consumer."},
	{"q": "They are organisms that breaks down dead organic matter.", "options": ["Primary", "Secondary", "Decomposer"], "answer": "Decomposer", "clue": "Nature’s clean-up crew or recyclers."}
]
var failed_questions = []

func _ready():
	randomize() 
	questions.shuffle()

	$UserInterface/Control/QuestionBox.hide()
	$UserInterface/Control/TimerContainer.hide()
	win_popup.hide() 
	lose_popup.hide() 

	$btn/Choice1.show()
	$btn/Choice2.show()
	$btn/Choice3.show()

	$btn/BlackBG/PopupHolder/Next.disabled = false
	$btn/BlackBG/PopupHolder/Next.modulate = Color(0.5, 0.5, 0.5)

	GameManager.set_current_island("island_3")
	GameManager.set_allowed_skills(["hint", "add_time", "freeze_time", "skip"])
	GameManager.hint_requested.connect(_on_hint_used)
	GameManager.freeze_requested.connect(_on_freeze_used)
	GameManager.add_time_requested.connect(_on_add_time_used)
	GameManager.skip_requested.connect(_on_skip_used)
	GameManager.settings_opened.connect(_on_settings_opened)
	GameManager.settings_closed.connect(_on_settings_closed)
	await get_tree().create_timer(0.1).timeout
	GameManager.update_skill_button_states()

	if GameManager.wand_used:
		wand_button.disabled = true
		wand_button.modulate = Color(0.5, 0.5, 0.5, 1)

	mission_label.text = "Become a Master Gardener! Answer questions correctly to help your seeds grow into beautiful plants.\n\nBe quick—you only have 1 minute and 20 seconds! Can you turn the Grove into a blooming paradise?"

	$Sprinkler.frame = 0
	$Plant1.frame = 0
	$Plant2.frame = 0
	$UserInterface/Control/ProgressBar.frame = 0

	start_entry_countdown()

# --- SKILL FUNCTIONS ---
func _on_hint_used():
	var data = questions[current_q]
	$UserInterface/Control/QuestionBox/QuestionText.text = data["q"] + "\n(Hint: " + data["clue"] + ")"

func _on_freeze_used():
	is_frozen = true
	await get_tree().create_timer(10.0).timeout
	is_frozen = false

func _on_add_time_used():
	time_left += 10.0

func _on_skip_used():
	sfx_correct.play()
	correct_answers += 1
	grow_garden()
	if correct_answers >= 6:
		show_win_popup()
	else:
		current_q += 1
		check_list_bounds()
		load_question()

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
	if timer_active and game_started and not is_frozen:
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

	$btn/Choice1/Label.text = choices[0]
	$btn/Choice2/Label.text = choices[1]
	$btn/Choice3/Label.text = choices[2]
	$UserInterface/Control/QuestionBox.show()

func check_answer(idx):
	if not game_started: return
	var selected_answer = get_node("btn/Choice" + str(idx + 1) + "/Label").text

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

func _on_settings_opened():
	$btn/WandHolder.hide()

func _on_settings_closed():
	$btn/WandHolder.show()

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

# --- Wand Logic ---
func _on_wand_pressed():
	if GameManager.wand_used or not game_started: return

	GameManager.wand_used = true
	wand_button.disabled = true
	wand_button.modulate = Color(0.5, 0.5, 0.5, 1)

	sfx_correct.play()
	correct_answers += 1
	grow_garden()

	if correct_answers >= 6:
		show_win_popup()
	else:
		current_q += 1
		check_list_bounds()
		load_question()

# --- Button Signals ---
func _on_back_pressed(): 
	GameManager.load_scene("res://Assets/Scene/BloomsGrove/science.scn") 
	$btn/BlackBG.hide()
	$btn/Choice1.hide()
	$btn/Choice2.hide()
	$btn/Choice3.hide()
	$btn/WandHolder.hide()

func _on_next_pressed(): 
	GameManager.load_scene("res://Assets/Scene/BloomsGrove/Minigame2.tscn") 
	win_popup.hide()
	$btn/Choice1.hide()
	$btn/Choice2.hide()
	$btn/Choice3.hide()
	$btn/WandHolder.hide()

func _on_try_pressed(): 
	GameManager.load_scene(get_tree().current_scene.scene_file_path) 
	$btn/ColorRect.hide()
	$btn.hide()

func _on_texture_button_pressed(): 
	GameManager.load_scene("res://Assets/Scene/BloomsGrove/science.scn") 
	$btn/ColorRect.hide()
	$btn/WandHolder.hide()
	$btn.hide()

func _on_choice_1_pressed(): check_answer(0)
func _on_choice_2_pressed(): check_answer(1)
func _on_choice_3_pressed(): check_answer(2)

func _on_collect_pressed() -> void:
	GameManager.receive_island_reward("island_3")
	GameManager.complete_minigame("island_3")
	$btn/BlackBG/PopupHolder/Next.disabled = false
	$btn/BlackBG/PopupHolder/Next.modulate = Color(1, 1, 1)	
