extends Node2D

# 1. Node References
@onready var lesson_label = $lesson_content
@onready var lesson_image = $lessonImage4
@onready var next_button = $next_btn
@onready var back_button = $back_btn
@onready var done_button = $done_btn 

# Reflection UI References
@onready var container_1 = $header_container1
@onready var container_2 = $header_container2
@onready var board_1 = $answer_board1
@onready var board_2 = $answer_board2

# PERSISTENCE: Unique static variable to hold division answers across scene changes
static var saved_div_data = {"board1": "", "board2": ""}

# 2. Image Preloads
var img_div_sign = preload("res://Assets/Sprite/Objects/study_session/division Sign.png")
var img_div_rule = preload("res://Assets/Sprite/Objects/study_session/division rule.png")
var img_stars = preload("res://Assets/Sprite/Objects/study_session/Stars.png")
var img_hearts = preload("res://Assets/Sprite/Objects/study_session/Hearts.png")
var img_div_fin = preload("res://Assets/Sprite/Objects/study_session/division_fin.png")
var img_div_ans = preload("res://Assets/Sprite/Objects/study_session/division_ans.png")

# 3. Content Pages
var pages = [
	{
		"text": "[color=black][b]Division[/b] is a fundamental arithmetic operation that involves splitting a total amount into equal groups, sharing items fairly, or determining how many times one number fits inside another.\n\n[b]Division Symbol[/b] - The division symbol, often called an obelus, indicates the operation of dividing a dividend by a divisor. It represents sharing or grouping a total into equal parts.[/color]",
		"texture": img_div_sign
	},
	{
		"text": "[color=black][b]Divisibility Rules[/b]\n\n[b]Rule of 1:[/b] Every number is divisible by 1. The answer is the number itself.\n\n[b]Rule of 2:[/b] Divisible if the last digit is even (0, 2, 4, 6, 8).\n\n[b]Rule of 3:[/b] Divisible if the sum of the digits is divisible by 3.\n\n[b]Rule of 4:[/b] Divisible if the last two digits are divisible by 4.\n\n[b]Rule of 5:[/b] Divisible if the number ends in 0 or 5.[/color]",
		"texture": img_div_rule
	},
	{
		"text": "[color=black][b]The Star Example[/b]\n\nIn this example, we see how division helps us organize a large group into smaller, equal parts. We start with a total of [b]10 stars[/b]. By dividing them into [b]2 equal groups[/b], we can see that each group contains exactly [b]5 stars[/b].\n\nThis visual represents the mathematical equation [b]10 / 2 = 5[/b].[/color]",
		"texture": img_stars
	},
	{
		"text": "[color=black][b]The Heart Example[/b]\n\nThis example demonstrates division using a slightly larger set. We begin with a total of [b]12 hearts[/b]. If we want to find out how many hearts fit into four even sections, we divide by 4.\n\nAs shown in the image, this results in [b]4 groups of 3 hearts[/b] each (12 / 4 = 3).[/color]",
		"texture": img_hearts
	},
	{
		"text": "[color=black][b]School Event – Chairs[/b]\n\nThere are [b]20 chairs[/b] arranged equally in [b]4 rows[/b]. \n\n[b]How many chairs are in each row?[/b]\n\n[i]Think: You are splitting 20 into 4 equal groups. What number multiplied by 4 gives you 20?[/i][/color]",
		"texture": img_div_fin
	},
	{
		"text": "[color=black][b]School Event – Chairs (Solution)[/b]\n\n[b]Problem:[/b]\nThere are 20 chairs arranged equally in 4 rows.\n\n[b]Solution:[/b]\n20 ÷ 4 = 5\n\n[b]Answer:[/b]\nEach row has [b]5 chairs![/b][/color]",
		"texture": img_div_ans
	},
	{
		"text": "", # THE REFLECTION PAGE
		"texture": null
	}
]

var current_page = 0

func _ready() -> void:
	# LOAD: Fill the boards with previously saved text
	board_1.text = GameManager.get_study_answer("division", "answer1")
	board_2.text = GameManager.get_study_answer("division", "answer2")
	
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
		# ANTI-CUTOFF: Ensure boards don't block mouse input on lesson pages
		board_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		done_button.visible = false

func check_word_count_requirement():
	# SAVE: Store text in static var as the player types
	GameManager.save_study_answer("division", "answer1", board_1.text)
	GameManager.save_study_answer("division", "answer2", board_2.text)
	
	var words1 = board_1.text.strip_edges().split(" ", false).size()
	var words2 = board_2.text.strip_edges().split(" ", false).size()
	
	if current_page == pages.size() - 1:
		done_button.visible = (words1 >= 10 and words2 >= 10)
	else:
		done_button.visible = false

# --- SIGNALS ---

func _on_answer_board_1_text_changed() -> void:
	check_word_count_requirement()

func _on_answer_board_2_text_changed() -> void:
	check_word_count_requirement()

func _on_cancel_btn_pressed() -> void:
	# Save progress before leaving via cancel
	saved_div_data["board1"] = board_1.text
	saved_div_data["board2"] = board_2.text
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/countoria/studysession_countoria.tscn")

func _on_next_btn_pressed() -> void:
	if current_page < pages.size() - 1:
		current_page += 1
		update_page_display()

func _on_back_btn_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		update_page_display()

func _on_done_btn_pressed() -> void:
	# Final Save before returning to the main menu
	saved_div_data["board1"] = board_1.text
	saved_div_data["board2"] = board_2.text
	GameManager.add_diamonds(1)
	GameManager.complete_study_topic("math")
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/countoria/studysession_countoria.tscn")
