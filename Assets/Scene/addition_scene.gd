extends Node2D

# 1. Node References
@onready var lesson_label = $lesson_content
@onready var lesson_image = $lessonImage
@onready var next_button = $next_btn
@onready var back_button = $back_btn
@onready var done_button = $done_btn 

@onready var container_1 = $header_container1
@onready var container_2 = $header_container2
@onready var board_1 = $answer_board1
@onready var board_2 = $answer_board2

# PERSISTENCE: This stays in memory so the player's answer doesn't reset
static var saved_addition_answers = {"board1": "", "board2": ""}

# 2. Image Preloads
var img_plus_sign = preload("res://Assets/Sprite/Objects/study_session/Addition Symbols.png")
var img_examples = preload("res://Assets/Sprite/Objects/study_session/Addition Examples.png")
var img_addition_prob = preload("res://Assets/Sprite/Objects/study_session/Addition.png")
var img_add_quiz = preload("res://Assets/Sprite/Objects/study_session/addquiz.png")
var img_final_prob = preload("res://Assets/Sprite/Objects/study_session/final_prob_add.png")
var img_final_ans = preload("res://Assets/Sprite/Objects/study_session/final_ans_add.png")

# 3. Content Pages
var pages = [
	{
		"text": "[color=black][b]Addition[/b] is a fundamental arithmetic operation that combines two or more numbers (addends) into a single total or sum.\n\n[b]Addition Symbol[/b] - Denoted as (+) and commonly called a plus sign. It signifies that the numbers on either side should be added together, indicating an increase or total.[/color]",
		"texture": img_plus_sign
	},
	{
		"text": "[color=black][b]The Match Stick Example[/b]\nIn this example, we combine two groups. The first group of 4 sticks and the second group of 3 sticks are called [b]addends[/b]. We use the plus sign (+) to join them. The equal sign (=) shows the final result: a [b]sum[/b] of 7 sticks.\n\n[b]The Apple Example[/b]\nWe start with 3 apples and join them with 2 apples. The plus sign (+) acts as a command to put all fruit into a single pile. When combined, the [b]sum[/b] is 5 apples.[/color]",
		"texture": img_examples
	},
	{
		"text": "[color=black][b]Problem:[/b]\nAna saved ₱275 in January and ₱348 in February.\n\n[b]How much money did she save in all?[/b]\n\n[b]Given:[/b] ₱275 + ₱348\n[b]Operation:[/b] Addition (+)\n[b]Solving:[/b] 275 + 348 = 623\n\n[b]Answer:[/b] Ana saved [b]₱623[/b] in all.[/color]",
		"texture": img_addition_prob
	},
	{
		"text": "[color=black][b]Practice Examples[/b]\n\nHere are some examples of 2-digit and 3-digit addition. Look closely at how we align the ones, tens, and hundreds columns to find the correct sum![/color]",
		"texture": img_add_quiz
	},
	{
		"text": "[color=black][b]Final Challenge: The School Fundraiser[/b]\n\nA school fundraiser collected ₱1,458 from Grade 4, ₱2,376 from Grade 5, and ₱1,689 from Grade 6. \n\n[b]How much money did they collect in all?[/b]\n\n[i]Try adding these three numbers together. Remember to carry over carefully when a column exceeds 9![/i][/color]",
		"texture": img_final_prob
	},
	{
		"text": "[color=black][b]Fundraiser Solution[/b]\n\n[b]Problem:[/b]\nA school fundraiser collected ₱1,458 from Grade 4, ₱2,376 from Grade 5, and ₱1,689 from Grade 6. \n\n[b]Solution:[/b]\n₱1,458 + ₱2,376 + ₱1,689 = 5,523\n\n[b]Answer:[/b]\nThey collected [b]₱5,523[/b] in total.[/color]",
		"texture": img_final_ans
	},
	{
		"text": "", # Reflection Page
		"texture": null
	}
]

var current_page = 0

func _ready() -> void:
	# Load previous answers
	board_1.text = saved_addition_answers["board1"]
	board_2.text = saved_addition_answers["board2"]
	
	done_button.visible = false
	_toggle_reflection_ui(false)
	update_page_display()

func update_page_display():
	var data = pages[current_page]
	lesson_label.text = data["text"]
	lesson_image.texture = data["texture"]
	lesson_image.visible = (data["texture"] != null)
	
	var is_reflection_page = (current_page == pages.size() - 1)
	_toggle_reflection_ui(is_reflection_page)
	
	next_button.visible = current_page < pages.size() - 1
	back_button.visible = current_page > 0

func _toggle_reflection_ui(show: bool):
	container_1.visible = show
	container_2.visible = show
	board_1.visible = show
	board_2.visible = show
	
	if show:
		# Boards become interactive
		board_1.mouse_filter = Control.MOUSE_FILTER_STOP
		board_2.mouse_filter = Control.MOUSE_FILTER_STOP
		check_word_count_requirement()
	else:
		# CRITICAL: Boards IGNORE mouse so they don't block text below them
		board_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		done_button.visible = false

func check_word_count_requirement():
	# Update saved memory as they type
	saved_addition_answers["board1"] = board_1.text
	saved_addition_answers["board2"] = board_2.text
	
	var words1 = board_1.text.strip_edges().split(" ", false).size()
	var words2 = board_2.text.strip_edges().split(" ", false).size()
	
	if current_page == pages.size() - 1 and words1 >= 10 and words2 >= 10:
		done_button.visible = true
	else:
		done_button.visible = false

# --- SIGNALS ---

func _on_answer_board_1_text_changed():
	check_word_count_requirement()

func _on_answer_board_2_text_changed():
	check_word_count_requirement()

func _on_cancel_btn_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/countoria/studysession_countoria.tscn")

func _on_next_btn_pressed():
	if current_page < pages.size() - 1:
		current_page += 1
		update_page_display()

func _on_back_btn_pressed():
	if current_page > 0:
		current_page -= 1
		update_page_display()

func _on_done_btn_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/countoria/studysession_countoria.tscn")
