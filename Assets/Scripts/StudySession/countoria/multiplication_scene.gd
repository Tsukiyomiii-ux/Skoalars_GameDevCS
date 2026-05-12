extends Node2D

# 1. Node References
@onready var lesson_label = $lesson_content
@onready var lesson_image = $lessonImage3
@onready var next_button = $next_btn
@onready var back_button = $back_btn
@onready var done_button = $done_btn 

@onready var container_1 = $header_container1
@onready var container_2 = $header_container2
@onready var board_1 = $answer_board1
@onready var board_2 = $answer_board2

# PERSISTENCE: Unique static variable for multiplication
static var saved_multi_data = {"board1": "", "board2": ""}

# 2. Image Preloads
var img_multi_sign = preload("res://Assets/Sprite/Objects/study_session/Multiplication Sign.png")
var img_multi_chart = preload("res://Assets/Sprite/Objects/study_session/Multiple chart.png")
var img_multi_table = preload("res://Assets/Sprite/Objects/study_session/Multiplication Table.png")
var img_2digit_multi = preload("res://Assets/Sprite/Objects/study_session/2digit_multiplication.png")
var img_perimeter_prob = preload("res://Assets/Sprite/Objects/study_session/perimeter.png")
var img_perimeter_ans = preload("res://Assets/Sprite/Objects/study_session/perimeter_ans.png")

# 3. Content Pages
var pages = [
	{
		"text": "[color=black][font_size=24][b]Multiplication[/b][/font_size]\nMultiplication is a fundamental arithmetic operation that represents the repeated addition of the same number, serving as a shortcut for calculating the total (product) of equal groups.\n\n[b]Multiplication Sign[/b] - The multiplication symbol (x, ·, or *) is a mathematical operator placed between two numbers to indicate repeated addition, often called the 'times' sign.[/color]",
		"texture": img_multi_sign
	},
	{
		"text": "[color=black][font_size=24][b]Multiplication Chart[/b][/font_size]\nA multiplication chart is a grid-based tool that visually displays the product of two numbers. It acts as a reference for memorizing multiplication facts and understanding multiplication as repeated addition.\n\n[b]Usage Example:[/b]\nTo find (4 x 6), look for 4 in the left column and move horizontally to the column headed by 6. The number at the intersection is the product: 24.[/color]",
		"texture": img_multi_chart
	},
	{
		"text": "[color=black][font_size=24][b]Another Example of Multiplication Chart![/b][/font_size]\n\nIn this chart, you are looking at multiplication, which is essentially repeated addition. The numbers in each colorful column are called [b]factors[/b]. When you multiply two factors together, the result is called the [b]product[/b].\n\nFor example, in the 'Three' column, you can see that adding 3 four times (3 + 3 + 3 + 3) gives you the product of [b]12[/b]. This chart serves as a reference guide to help you memorize these patterns.[/color]",
		"texture": img_multi_table
	},
	{
		"text": "[color=black][font_size=24][b]2-digit Multiplication[/b][/font_size]\n\n[b]Step 1: Multiply the Ones[/b]\nMultiply 34 by 2. First, 2 × 4 = 8, then 2 × 3 = 6, so the first answer is [b]68[/b].\n\n[b]Step 2: Multiply the Tens[/b]\nMultiply 34 by 1. Since 1 means 10, write [b]0[/b] at the end first. Then 1 × 4 = 4 and 1 × 3 = 3, so the second answer is [b]340[/b].\n\n[b]Step 4: Add the Answers[/b]\nAdd 68 + 340. The total is [b]408[/b], so 34 × 12 = 408.\n\n[i]⭐ Note: This pattern works for bigger numbers too! Just add one more zero for each new row (00 for hundreds, etc.) and add all rows together at the end.[/i][/color]",
		"texture": img_2digit_multi
	},
	{
		"text": "[color=black][font_size=24][b]Try to Answer this Practice Problem![/b][/font_size]\n\n[b]Perimeter of a Square Garden[/b]\nA square garden has a side length of 4 meters. Can you figure out its perimeter?\n\n[i]Think: A square has 4 sides that are all the same length. How would you calculate the total distance around it?[/i][/color]",
		"texture": img_perimeter_prob
	},
	{
		"text": "[color=black][font_size=24][b]Perimeter of a Square Garden - Solution[/b][/font_size]\n\n[b]Problem:[/b]\nA square garden has each side measuring 4 meters. What is the perimeter of the garden?\n\n[b]Solution:[/b]\nA square has 4 equal sides, so we add all sides:\n4 + 4 + 4 + 4 = 16\n\n[b]Or using Multiplication:[/b]\n4 × 4 = 16\n\n[b]Answer:[/b]\nThe perimeter of the garden is [b]16 meters[/b].[/color]",
		"texture": img_perimeter_ans
	},
	{
		"text": "", # Reflection Page
		"texture": null
	}
]

var current_page = 0

func _ready() -> void:
	# LOAD PREVIOUS ANSWERS
	board_1.text = saved_multi_data["board1"]
	board_2.text = saved_multi_data["board2"]
	
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
		# Enable interaction
		board_1.mouse_filter = Control.MOUSE_FILTER_STOP
		board_2.mouse_filter = Control.MOUSE_FILTER_STOP
		check_word_count_requirement()
	else:
		# PREVENT CUT-OFF: Disable mouse detection when not on reflection page
		board_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		done_button.visible = false

func check_word_count_requirement():
	# PERSISTENCE: Save to static memory as they type
	saved_multi_data["board1"] = board_1.text
	saved_multi_data["board2"] = board_2.text
	
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
	# Ensure text is saved before leaving
	saved_multi_data["board1"] = board_1.text
	saved_multi_data["board2"] = board_2.text
	get_tree().change_scene_to_file("res://Assets/Scene/studysession_countoria.tscn")

func _on_next_btn_pressed() -> void:
	if current_page < pages.size() - 1:
		current_page += 1
		update_page_display()

func _on_back_btn_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		update_page_display()

func _on_done_btn_pressed() -> void:
	# Force final save
	saved_multi_data["board1"] = board_1.text
	saved_multi_data["board2"] = board_2.text
	get_tree().change_scene_to_file("res://Assets/Scene/studysession_countoria.tscn")
