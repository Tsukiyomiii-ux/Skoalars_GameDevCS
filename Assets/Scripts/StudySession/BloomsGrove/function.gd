extends CanvasLayer

var lessons = [
	{
		"name": "Roots",
		"functions": [
			"Absorbing water and minerals from the soil",
			"Storing food for future use",
			"Producing plant growth hormones",
			"Anchoring the plant firmly to the soil and providing support",
			"Developing new plants from the roots of the old plant"
		]
	},
	{
		"name": "Stem",
		"functions": [
			"Providing strength and support to buds, flowers, leaves, and fruits",
			"Storing food mainly in the form of starch",
			"Transporting food, water, and minerals to all parts of the plant body",
			"Developing new plants from the stem of the old plant"
		]
	},
	{
		"name": "Leaves",
		"functions": [
			"Making food for the plant through photosynthesis",
			"Helping in reproduction (e.g., Bryophyllum)",
			"Helping in evaporation by transpiration"
		]
	},
	{
		"name": "Flowers",
		"functions": [
			"Helping in the sexual reproduction of plants",
			"Stimulating pollination and fertilization of the ovule"
		]
	},
	{
		"name": "Fruits",
		"functions": [
			"Protecting the growing seeds",
			"Helping in the dispersal of seeds and reproduction"
		]
	}
]

var current_index = 0
var word_requirement = 10

# Main Topic Nodes
@onready var topic_name_container = $Bg/VBoxContainer
@onready var topic_name_label = $Bg/VBoxContainer/Name
@onready var topic_functions_container = $Bg/VBoxContainer2
@onready var topic_functions_label = $Bg/VBoxContainer2/Functions

# Assessment Nodes
@onready var answer1_field = $Answer1
@onready var answer2_field = $Answer2
@onready var question1_container = $VBoxContainer
@onready var question2_container = $VBoxContainer2

# Control Nodes
@onready var next_button = $Bg/Next
@onready var back_button = $Bg/Back
@onready var done_button = $Bg/Done

func _ready():
	# 1. LOAD: Pull existing text from GameManager immediately
	answer1_field.text = GameManager.get_study_answer("plant_functions", "answer1")
	answer2_field.text = GameManager.get_study_answer("plant_functions", "answer2")
	
	# Connect signals
	answer1_field.text_changed.connect(_on_answers_changed)
	answer2_field.text_changed.connect(_on_answers_changed)
	
	update_page()

func update_page():
	# Reset visibility
	topic_name_container.visible = false
	topic_functions_container.visible = false
	answer1_field.visible = false
	answer2_field.visible = false
	question1_container.visible = false
	question2_container.visible = false
	next_button.visible = false
	done_button.visible = false
	
	if current_index < lessons.size():
		# --- TOPIC MODE ---
		topic_name_container.visible = true
		topic_functions_container.visible = true
		next_button.visible = true
		
		var data = lessons[current_index]
		topic_name_label.text = "[center][b][font_size=48]" + data["name"] + "[/font_size][/b][/center]"
		
		var formatted_text = ""
		for item in data["functions"]:
			formatted_text += "• " + item + "\n\n"
		topic_functions_label.text = formatted_text
	else:
		# --- ASSESSMENT MODE ---
		$Bg.visible = true
		answer1_field.visible = true
		answer2_field.visible = true
		question1_container.visible = true
		question2_container.visible = true
		
		# Check if the Done button should show based on loaded/typed text
		_on_answers_changed()

	back_button.visible = current_index > 0

func _on_answers_changed():
	GameManager.save_study_answer("plant_functions", "answer1", answer1_field.text)
	GameManager.save_study_answer("plant_functions", "answer2", answer2_field.text)
	
	if current_index >= lessons.size():
		var words1 = answer1_field.text.split(" ", false).size()
		var words2 = answer2_field.text.split(" ", false).size()
		
		done_button.visible = (words1 >= word_requirement and words2 >= word_requirement)
		print("✅ done_button.visible = ", done_button.visible, " | words: ", words1, ", ", words2)
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
	GameManager.complete_study_topic("science","plant_functions")
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")

func _on_cancel_pressed():
	GameManager.load_scene("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")
