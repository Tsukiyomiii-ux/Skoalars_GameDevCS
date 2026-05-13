extends CanvasLayer
var lessons = [
	{
		"title": "Roots", 
		"desc": "Part of the plant that lies below the soil.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Roots.png") 
	},
	{
		"title": "Stem", 
		"desc": "Supports the leaves and conducts water and minerals.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Trunk.png") 
	},
	{
		"title": "Leaves", 
		"desc": "The primary site of photosynthesis in most plants.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Leaves.png") 
	},
	{
		"title": "Flowers", 
		"desc": "The reproductive part of the flowering plant.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Flower.png") 
	},
	{
		"title": "Fruit", 
		"desc": "The seed-bearing structure in flowering plants.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Fruits.png") 
	}
]
var current_index = 0
var word_requirement = 10
# Lesson UI Nodes
@onready var lesson_label = $Bg/VBoxContainer/Lesson
@onready var lesson_image = $Bg/LessonImage 
@onready var next_button = $Bg/Next
@onready var back_button = $Bg/Back
@onready var done_button = $Bg/Done
# Question UI Nodes
@onready var question_container_1 = $Bg/VBoxContainer2
@onready var answer_field_1 = $"Bg/Answer 1"
@onready var question_container_2 = $Bg/VBoxContainer3
@onready var answer_field_2 = $"Bg/Answer 2"

func _ready():
	AudioManager.play_music(preload("res://Assets/Audio/StudySessionBG.wav"))
	answer_field_1.text = GameManager.get_study_answer("plant_lesson", "answer1")
	answer_field_2.text = GameManager.get_study_answer("plant_lesson", "answer2")
	answer_field_1.text_changed.connect(_on_answers_changed)
	answer_field_2.text_changed.connect(_on_answers_changed)
	update_page()

func update_page():
	# Hide all conditional elements
	lesson_label.visible = false
	lesson_image.visible = false
	question_container_1.visible = false
	answer_field_1.visible = false
	question_container_2.visible = false
	answer_field_2.visible = false
	next_button.visible = false
	done_button.visible = false
	
	if current_index < lessons.size():
		lesson_label.visible = true
		lesson_image.visible = true
		next_button.visible = true
		
		var data = lessons[current_index]
		lesson_label.text = "[center][b][font_size=48]" + data["title"] + "[/font_size][/b]\n\n" + data["desc"] + "[/center]"
		lesson_image.texture = data["image"]
	else:
		# --- ASSESSMENT MODE ---
		question_container_1.visible = true
		answer_field_1.visible = true
		question_container_2.visible = true
		answer_field_2.visible = true
		
		_on_answers_changed()
	back_button.visible = current_index > 0

func _on_answers_changed():
	# Always update the Global GameManager so text is never lost
	GameManager.save_study_answer("plant_lesson", "answer1", answer_field_1.text)
	GameManager.save_study_answer("plant_lesson", "answer2", answer_field_2.text)
	
	if current_index >= lessons.size():
		# ✅ FIXED: use get_study_answer() instead of direct property access
		var words_1 = GameManager.get_study_answer("plant_lesson", "answer1").split(" ", false).size()
		var words_2 = GameManager.get_study_answer("plant_lesson", "answer2").split(" ", false).size()
		
		done_button.visible = (words_1 >= word_requirement and words_2 >= word_requirement)
	else:
		done_button.visible = false

func _on_next_pressed():
	if current_index < lessons.size():
		current_index += 1
		update_page()

func _on_back_pressed():
	if current_index > 0:
		current_index -= 1
		update_page()

func _on_done_pressed():
	if not GameManager.completed_topics.has("plant_lesson"):
		GameManager.add_diamonds(1)
	GameManager.complete_study_topic("science","plant_lesson")
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")

func _on_cancel_pressed():
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")
