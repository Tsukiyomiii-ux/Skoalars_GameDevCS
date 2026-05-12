extends Node2D

# 1. Node References
@onready var lesson_label = $lesson_content
@onready var lesson_image = $lessonImage2
@onready var next_button = $next_btn
@onready var back_button = $back_btn
@onready var done_button = $done_btn 

@onready var container_1 = $header_container1
@onready var container_2 = $header_container2
@onready var board_1 = $answer_board1
@onready var board_2 = $answer_board2

# UNIQUE PERSISTENCE: Ensure this name is different from Addition's static var
static var saved_sub_data = {"board1": "", "board2": ""}

# 2. Image Preloads
var img_minus_sign = preload("res://Assets/Sprite/Objects/study_session/14.png")
var img_sub_examples = preload("res://Assets/Sprite/Objects/study_session/subtraction examples.png")
var img_sub_problem = preload("res://Assets/Sprite/Objects/study_session/Subtraction.png")
var img_sub_quiz = preload("res://Assets/Sprite/Objects/study_session/subquiz.png")
var img_score_prob = preload("res://Assets/Sprite/Objects/study_session/sub_fin_prob.png")
var img_score_ans = preload("res://Assets/Sprite/Objects/study_session/sub_fin_answer.png")

# 3. Content Pages
var pages = [
	{
		"text": "[color=black][b]Subtraction[/b] is a foundational arithmetic operation used to determine the difference between two numbers or quantities, representing the process of 'taking away' or removing a smaller amount from a larger one.\n\n[b]Subtraction Sign[/b] - The subtraction symbol, commonly known as the minus sign (−), indicates the removal of a quantity or calculates the difference between two numbers.[/color]",
		"texture": img_minus_sign
	},
	{
		"text": "[color=black][b]The Bread Example[/b]\nWe start with a minuend of 12 breads. The minus sign (−) tells us we are removing 3 breads (the subtrahend). After taking them away, we are left with a [b]difference[/b] of 9 breads.\n\n[b]The Milk Example[/b]\nWe begin with 4 milk bottles and subtract 2 bottles. Once those 2 are removed from the starting four, the [b]difference[/b] is 2 milk bottles.[/color]",
		"texture": img_sub_examples
	},
	{
		"text": "[color=black][b]Subtraction Problem (Buying)[/b]\n\n[b]Problem:[/b] Carlo had ₱1,000. He bought a school bag worth ₱645.\n\n[b]How much money does he have left?[/b]\n\n[b]Given:[/b] ₱1,000 − ₱645\n[b]Operation:[/b] Subtraction (−)\n[b]Solving:[/b] 1,000 − 645 = 355\n\n[b]Answer:[/b] Carlo has [b]₱355[/b] left.[/color]",
		"texture": img_sub_problem
	},
	{
		"text": "[color=black][b]Practice Examples[/b]\n\nHere are some examples of 2-digit and 3-digit subtraction. Pay attention to how we 'borrow' from the next column when the top number is smaller than the bottom number![/color]",
		"texture": img_sub_quiz
	},
	{
		"text": "[color=black][b]Final Challenge: Game Score Deduction[/b]\n\nA player starts with 3,500 points in a game. They lose 425 points in round 1, 680 points in round 2, and 315 points in round 3. \n\n[b]What is their final score?[/b]\n\n[i]Think: Should you subtract each number one by one, or add the total points lost first?[/i][/color]",
		"texture": img_score_prob
	},
	{
		"text": "[color=black][b]Game Score Solution[/b]\n\n[b]Problem:[/b]\nA player starts with 3,500 points. They lose 425, 680, and 315 points.\n\n[b]Solution Step 1 (Total Loss):[/b]\n425 + 680 + 315 = 1,420\n\n[b]Solution Step 2 (Remaining Score):[/b]\n3,500 − 1,420 = 2,080\n\n[b]Answer:[/b]\nThe final score is [b]2,080 points[/b].[/color]",
		"texture": img_score_ans
	},
	{
		"text": "", # Reflection Page
		"texture": null
	}
]

var current_page = 0

func _ready() -> void:
	# 1. LOAD: Immediately pull the text from the static memory
	board_1.text = saved_sub_data["board1"]
	board_2.text = saved_sub_data["board2"]
	
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
		board_1.mouse_filter = Control.MOUSE_FILTER_STOP
		board_2.mouse_filter = Control.MOUSE_FILTER_STOP
		check_word_count_requirement() 
	else:
		board_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		done_button.visible = false

func check_word_count_requirement():
	# 2. CONTINUOUS SAVE: Store text in static var every time user types
	saved_sub_data["board1"] = board_1.text
	saved_sub_data["board2"] = board_2.text
	
	var words1 = board_1.text.strip_edges().split(" ", false).size()
	var words2 = board_2.text.strip_edges().split(" ", false).size()
	
	# Only show done if we are on the last page and word count is met
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
	# Save one last time before switching scenes
	saved_sub_data["board1"] = board_1.text
	saved_sub_data["board2"] = board_2.text
	get_tree().change_scene_to_file("res://Assets/Scene/studysession_countoria.tscn")

func _on_next_btn_pressed():
	if current_page < pages.size() - 1:
		current_page += 1
		update_page_display()

func _on_back_btn_pressed():
	if current_page > 0:
		current_page -= 1
		update_page_display()

func _on_done_btn_pressed():
	# FINAL SAVE: Commit to static memory
	saved_sub_data["board1"] = board_1.text
	saved_sub_data["board2"] = board_2.text
	get_tree().change_scene_to_file("res://Assets/Scene/studysession_countoria.tscn")
