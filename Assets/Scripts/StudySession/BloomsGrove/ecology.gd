extends CanvasLayer

var lessons = [
	{
		"name": "Producers",
		"definition": "Organisms that create their own food using sunlight or chemical energy, forming the foundation of ecosystem. They convert inorganic materials into organic molecules, supporting all higher trophic levels."
	},
	{
		"name": "Primary Consumers",
		"definition": "Are herbivores that feed directly on producers. They convert plant biomass into energy for higher-level carnivores."
	},
	{
		"name": "Secondary Consumers",
		"definition": "Are organisms that eat primary consumers for energy, acting as the third trophic level in an ecosystem."
	},
	{
		"name": "Tertiary Consumers",
		"definition": "Are carnivores or omnivores that occupy the fourth trophic level, feeding primarily on secondary consumers."
	},
	{
		"name": "Decomposers",
		"definition": "Are essential organisms that break down dead organic matter, waste and recycling nutrients."
	}
]

var current_index = 0
var word_requirement = 10

# Main Lesson Nodes
@onready var topic_container = $Bg/VBoxContainer
@onready var name_label = $Bg/VBoxContainer/Name
@onready var definition_container = $Bg/VBoxContainer2
@onready var definition_label = $Bg/VBoxContainer2/Definition

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
	# 1. LOAD: Pull saved text from GameManager immediately
	answer1.text = GameManager.get_study_answer("ecosystem", "answer1")
	answer2.text = GameManager.get_study_answer("ecosystem", "answer2")
	
	# Connect text changes to check for the 10-word requirement
	answer1.text_changed.connect(_on_answers_changed)
	answer2.text_changed.connect(_on_answers_changed)
	
	update_page()

func update_page():
	# Hide everything by default
	topic_container.visible = false
	definition_container.visible = false
	answer1.visible = false
	answer2.visible = false
	question1_vbox.visible = false
	question2_vbox.visible = false
	next_button.visible = false
	done_button.visible = false
	
	if current_index < lessons.size():
		# --- LESSON MODE ---
		topic_container.visible = true
		definition_container.visible = true
		next_button.visible = true
		
		var data = lessons[current_index]
		name_label.text = "[center][b][font_size=48]" + data["name"] + "[/font_size][/b][/center]"
		definition_label.text = data["definition"]
	else:
		# --- ASSESSMENT MODE ---
		answer1.visible = true
		answer2.visible = true
		question1_vbox.visible = true
		question2_vbox.visible = true
		
		# Refresh the state of the Done button based on existing text
		_on_answers_changed()

	back_button.visible = current_index > 0

func _on_answers_changed():
	# 2. SAVE: Push current text to GameManager every time it changes
	GameManager.save_study_answer("ecosystem", "answer1", answer1.text)
	GameManager.save_study_answer("ecosystem", "answer2", answer2.text)
	
	if current_index >= lessons.size():
		var count1 = answer1.text.split(" ", false).size()
		var count2 = answer2.text.split(" ", false).size()
		
		# Done button only appears when both fields have at least 10 words
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
	GameManager.complete_study_topic("science")
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")

func _on_cancel_pressed():
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")
