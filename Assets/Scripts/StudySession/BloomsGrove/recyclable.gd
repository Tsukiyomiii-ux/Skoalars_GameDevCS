extends CanvasLayer

var lessons = [
	{
		"name": "Can / Tin Can",
		"definition": "Metal containers that can be melted down to make new food cans.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/TinCan.png")
	},
	{
		"name": "Cardboard",
		"definition": "Thick brown paper that can be mashed up to make new boxes.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Cardboard.png")
	},
	{
		"name": "Glass Bottle",
		"definition": "A hard bottle that can be washed or melted to make a new one.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/GlassBottle.png")
	},
	{
		"name": "Newspaper",
		"definition": "Old news pages that can be soaked and turned into clean new paper.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Newspaper.png")
	},
	{
		"name": "Plastic / Tea Bottle",
		"definition": "Plastic bottles that can be shredded and turned into new toys or bottles.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/TeaBottle.png")
	},
	{
		"name": "Paper Bag / Plate",
		"definition": "Paper items that can be recycled to save more trees from being cut down.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/PaperBag.png")
	}
]

var current_index = 0
var word_requirement = 10

@onready var trash_image = $Bg/Trash
@onready var definition_label = $Bg/VBoxContainer/Trash
@onready var study_layout = $Bg/VBoxContainer
@onready var next_button = $Bg/Next
@onready var back_button = $Bg/Back
@onready var done_button = $Bg/Done

# Question Page Nodes
@onready var question_container_1 = $VBoxContainer2
@onready var answer_field_1 = $"Answer 1"
@onready var question_container_2 = $VBoxContainer3
@onready var answer_field_2 = $"Answer 2"

func _ready():
	AudioManager.play_music(preload("res://Assets/Audio/StudySessionBG.wav"))
	# 1. LOAD: Restore text from GameManager immediately
	answer_field_1.text = GameManager.get_study_answer("recyclable_waste", "answer1")
	answer_field_2.text = GameManager.get_study_answer("recyclable_waste", "answer2")
	
	# Connect text changed signals
	answer_field_1.text_changed.connect(_on_answers_changed)
	answer_field_2.text_changed.connect(_on_answers_changed)
	
	update_page()

func update_page():
	# Reset visibility for Study Layout
	study_layout.visible = false
	trash_image.visible = false
	
	# Reset visibility for Question Layout
	question_container_1.visible = false
	answer_field_1.visible = false
	question_container_2.visible = false
	answer_field_2.visible = false
	
	# Reset Buttons
	next_button.visible = false
	done_button.visible = false
	
	if current_index < lessons.size():
		# --- LESSON MODE ---
		study_layout.visible = true
		trash_image.visible = true
		next_button.visible = true
		
		var data = lessons[current_index]
		trash_image.texture = data["image"]
		definition_label.text = "[center][b][font_size=48]" + data["name"] + "[/font_size][/b][/center]\n\n" + data["definition"]
	else:
		# --- ASSESSMENT MODE ---
		question_container_1.visible = true
		answer_field_1.visible = true
		question_container_2.visible = true
		answer_field_2.visible = true
		
		# Initial check for button visibility based on existing text
		_on_answers_changed() 

	back_button.visible = current_index > 0

func _on_answers_changed():
	# 2. SAVE: Sync current text to GameManager variables instantly
	GameManager.save_study_answer("recyclable_waste", "answer1", answer_field_1.text)
	GameManager.save_study_answer("recyclable_waste", "answer2", answer_field_2.text)
	
	if current_index >= lessons.size():
		var words_1 = answer_field_1.text.split(" ", false).size()
		var words_2 = answer_field_2.text.split(" ", false).size()
		
		# Show Done button when word counts are met
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
	GameManager.add_diamonds(1)
	GameManager.complete_study_topic("science","recyclable")
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")

func _on_cancel_pressed():
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")
