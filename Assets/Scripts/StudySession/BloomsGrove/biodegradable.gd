extends CanvasLayer

var lessons = [
	{
		"name": "Apple Leftover",
		"definition": "A fruit snack that tiny bugs can eat to turn it into soil.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Apple.png")
	},
	{
		"name": "Banana Peel",
		"definition": "A slippery fruit skin that naturally disappears in the garden.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Banana.png")
	},
	{
		"name": "Coconut Shell",
		"definition": "A hard shell from a plant that will slowly break down over time.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Coconutshell.png")
	},
	{
		"name": "Egg Shell",
		"definition": "A crunchy shell that provides vitamins to the soil as it rots.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Eggshell.png")
	},
	{
		"name": "Fried Chicken Bone",
		"definition": "Part of an animal that nature can break down slowly.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/FriedChickenBone.png")
	},
	{
		"name": "Leaves",
		"definition": "Parts of a tree that fall and become food for the earth.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/TLeaves.png")
	},
	{
		"name": "Twig",
		"definition": "A small piece of a wooden branch that rots and turns into dirt.",
		"image": preload("res://Assets/Bloom Game 1/Study Session/Twig.png")
	}
]

var current_index = 0
var word_requirement = 2

# Lesson Content Nodes
@onready var trash_image = $Bg/Trash
@onready var study_vbox = $Bg/VBoxContainer
@onready var definition_label = $Bg/VBoxContainer/Trash

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
	answer1.text = GameManager.get_study_answer("bio_waste", "answer1")
	answer2.text = GameManager.get_study_answer("bio_waste", "answer2")
	
	# Connect text changed signals
	answer1.text_changed.connect(_on_answers_changed)
	answer2.text_changed.connect(_on_answers_changed)
	
	update_page()

func update_page():
	trash_image.visible = false
	study_vbox.visible = false
	answer1.visible = false
	answer2.visible = false
	question1_vbox.visible = false
	question2_vbox.visible = false
	next_button.visible = false
	done_button.visible = false
	
	if current_index < lessons.size():
		# --- TOPIC MODE ---
		trash_image.visible = true
		study_vbox.visible = true
		next_button.visible = true
		
		var data = lessons[current_index]
		trash_image.texture = data["image"]
		definition_label.text = "[center][b][font_size=48]" + data["name"] + "[/font_size][/b][/center]\n\n" + data["definition"]
	else:
		# --- ASSESSMENT MODE ---
		answer1.visible = true
		answer2.visible = true
		question1_vbox.visible = true
		question2_vbox.visible = true
		
		_on_answers_changed()

	back_button.visible = current_index > 0

func _on_answers_changed():
	# 2. SAVE: Sync current text to GameManager every time it changes
	GameManager.save_study_answer("bio_waste", "answer1", answer1.text)
	GameManager.save_study_answer("bio_waste", "answer2", answer2.text)
	
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
	GameManager.add_diamonds(1)
	GameManager.complete_study_topic("science","bio_waste")
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")

func _on_cancel_pressed():
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")
