extends CanvasLayer

var lessons = [
	{
		"name": "Broken Glass",
		"definition": "Sharp pieces of glass that stay in the dirt forever and never rot.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/BrokenGlass.png")
	},
	{
		"name": "Chips Wrapper",
		"definition": "A shiny plastic bag that will never disappear if left on the ground.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/ChipsWrapper.png")
	},
	{
		"name": "Lightbulb",
		"definition": "A glass and metal object that cannot be eaten by nature.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/LightBulb.png")
	},
	{
		"name": "Plastic Bag",
		"definition": "A stretchy bag that harms animals and never turns into soil.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/PlasticBag.png")
	},
	{
		"name": "Styrofoam",
		"definition": "A fluffy white material that stays in the trash pile for hundreds of years.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Styrofoam.png")
	}
]

var current_index = 0
var word_requirement = 10

# Lesson Content Nodes
@onready var trash_image = $Bg/Trash
@onready var study_vbox = $Bg/VBoxContainer
@onready var trash_label = $Bg/VBoxContainer/Trash

# Assessment Nodes
@onready var answer1 = $Answer1
@onready var answer2 = $Answer2
@onready var question1_vbox = $VBoxContainer 
@onready var question2_vbox = $VBoxContainer2 

# Navigation Nodes
@onready var next_button = $Bg/Next
@onready var back_button = $Bg/Back
@onready var done_button = $Bg/Done

func _ready():
	# 1. LOAD: Restore text from GameManager when the scene starts
	answer1.text = GameManager.non_bio_waste_answer1
	answer2.text = GameManager.non_bio_waste_answer2
	
	# Connect text changed signals
	answer1.text_changed.connect(_on_answers_changed)
	answer2.text_changed.connect(_on_answers_changed)
	
	update_page()

func update_page():
	# Hide assessment elements by default
	answer1.visible = false
	answer2.visible = false
	question1_vbox.visible = false
	question2_vbox.visible = false
	done_button.visible = false
	
	# Hide lesson elements by default
	trash_image.visible = false
	study_vbox.visible = false
	next_button.visible = false
	
	if current_index < lessons.size():
		# --- TOPIC MODE ---
		trash_image.visible = true
		study_vbox.visible = true
		next_button.visible = true
		
		var data = lessons[current_index]
		trash_image.texture = data["image"]
		trash_label.text = "[center][b][font_size=48]" + data["name"] + "[/font_size][/b][/center]\n\n" + data["definition"]
	else:
		# --- ASSESSMENT MODE ---
		answer1.visible = true
		answer2.visible = true
		question1_vbox.visible = true
		question2_vbox.visible = true
		
		# Check if button should show based on loaded text
		_on_answers_changed()

	back_button.visible = current_index > 0

func _on_answers_changed():
	# 2. SAVE: Sync current text to GameManager every time it changes
	GameManager.non_bio_waste_answer1 = answer1.text
	GameManager.non_bio_waste_answer2 = answer2.text
	
	if current_index >= lessons.size():
		var count1 = answer1.text.split(" ", false).size()
		var count2 = answer2.text.split(" ", false).size()
		
		done_button.visible = (count1 >= word_requirement and count2 >= word_requirement)

func _on_next_pressed():
	if current_index < lessons.size():
		current_index += 1
		update_page()

func _on_back_pressed():
	if current_index > 0:
		current_index -= 1
		update_page()

func _on_done_pressed():
	GameManager.complete_study_topic("science")
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")

func _on_cancel_pressed():
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")
