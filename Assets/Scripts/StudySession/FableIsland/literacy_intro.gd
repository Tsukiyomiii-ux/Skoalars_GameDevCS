extends Control

# --- 1. VARIABLES ---
var current_page_index : int = 1
var _from_topic_buttons : bool = false
var _pending_topic_index : int = 1

var completed_topics : Dictionary = {
	"noun": false,
	"adjective": false,
	"pronouns": false,
	"verb": false,
	"adverb": false,
	"conjunction": false
}

var page6_indices : Array = [6, 12, 18, 24, 30, 36]
var topic_first_pages : Array = [1, 7, 13, 19, 25, 31]

# --- 2. NODES ---
@onready var book_container = $Control
@onready var topic_screen = $Control2/TopicButtons

@onready var page_list = [
	$Control/RulePage,
	$Control/NounPage,
	$Control/NounPage2,
	$Control/NounPage3,
	$Control/NounPage4,
	$Control/NounPage5,
	$Control/NounPage6,
	$Control/AdjectivePage,
	$Control/AdjectivePage2,
	$Control/AdjectivePage3,
	$Control/AdjectivePage4,
	$Control/AdjectivePage5,
	$Control/AdjectivePage6,
	$Control/PronounsPage,
	$Control/PronounsPage2,
	$Control/PronounsPage3,
	$Control/PronounsPage4,
	$Control/PronounsPage5,
	$Control/PronounsPage6,
	$Control/VerbPage,
	$Control/VerbPage2,
	$Control/VerbPage3,
	$Control/VerbPage4,
	$Control/VerbPage5,
	$Control/VerbPage6,
	$Control/AdverbPage,
	$Control/AdverbPage2,
	$Control/AdverbPage3,
	$Control/AdverbPage4,
	$Control/AdverbPage5,
	$Control/AdverbPage6,
	$Control/ConjunctionPage,
	$Control/ConjunctionPage2,
	$Control/ConjunctionPage3,
	$Control/ConjunctionPage4,
	$Control/ConjunctionPage5,
	$Control/ConjunctionPage6,
]

# --- 3. READY ---
func _ready():
	AudioManager.play_music(preload("res://Assets/Audio/StudySessionBG.wav"))
	_setup_recursive(self)
	book_container.hide()
	topic_screen.show()

func _setup_recursive(node: Node):
	for child in node.get_children():

		if child is RichTextLabel:
			child.selection_enabled = false

		if child is Label:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

		if child.name == "LearnedInput":
			# ✅ REMOVED: child.text = "" (we now restore saved text instead)
			child.placeholder_text = "Type your answers here (Minimum: 10 words)"
			child.selecting_enabled = false
			child.add_theme_color_override("background_color", Color(1, 1, 1, 1))
			child.add_theme_color_override("font_color", Color(0, 0, 0, 1))
			child.add_theme_color_override("font_placeholder_color", Color(0.5, 0.5, 0.5, 1))
			child.add_theme_color_override("caret_color", Color(0, 0, 0, 1))
			if not child.text_changed.is_connected(_on_learned_input_text_changed):
				child.text_changed.connect(_on_learned_input_text_changed)

		if child.name == "SurprisedInput":
			# ✅ REMOVED: child.text = "" (we now restore saved text instead)
			child.placeholder_text = "Type your answers here (Minimum: 10 words)"
			child.selecting_enabled = false
			child.add_theme_color_override("background_color", Color(1, 1, 1, 1))
			child.add_theme_color_override("font_color", Color(0, 0, 0, 1))
			child.add_theme_color_override("font_placeholder_color", Color(0.5, 0.5, 0.5, 1))
			child.add_theme_color_override("caret_color", Color(0, 0, 0, 1))
			if not child.text_changed.is_connected(_on_surprised_input_text_changed):
				child.text_changed.connect(_on_surprised_input_text_changed)

		if child.name == "CancelBtn":
			if not child.pressed.is_connected(_on_cancel_btn_pressed):
				child.pressed.connect(_on_cancel_btn_pressed)

		if child.name == "NextBtn":
			if not child.pressed.is_connected(_on_next_btn_pressed):
				child.pressed.connect(_on_next_btn_pressed)
			if not child.mouse_entered.is_connected(_on_any_btn_mouse_entered.bind(child)):
				child.mouse_entered.connect(_on_any_btn_mouse_entered.bind(child))
			if not child.mouse_exited.is_connected(_on_any_btn_mouse_exited.bind(child)):
				child.mouse_exited.connect(_on_any_btn_mouse_exited.bind(child))

		if child.name == "BackBtn":
			if not child.pressed.is_connected(_on_back_btn_pressed):
				child.pressed.connect(_on_back_btn_pressed)
			if not child.mouse_entered.is_connected(_on_any_btn_mouse_entered.bind(child)):
				child.mouse_entered.connect(_on_any_btn_mouse_entered.bind(child))
			if not child.mouse_exited.is_connected(_on_any_btn_mouse_exited.bind(child)):
				child.mouse_exited.connect(_on_any_btn_mouse_exited.bind(child))

		_setup_recursive(child)

# --- 4. NAVIGATION ---
func update_page_navigation():
	for p in page_list:
		if p: p.hide()
	if current_page_index < page_list.size():
		var current_page = page_list[current_page_index]
		current_page.show()
		current_page.modulate.a = 0
		create_tween().tween_property(current_page, "modulate:a", 1.0, 0.4)
		if current_page_index in page6_indices:
			var next_btn = current_page.get_node_or_null("NextBtn")
			if next_btn:
				next_btn.hide()
			_check_reflection_inputs()

func _go_to_topic_buttons():
	book_container.hide()
	topic_screen.show()
	_from_topic_buttons = false

func _go_to_book():
	topic_screen.hide()
	book_container.show()
	update_page_navigation()
	# ✅ NEW: Restore saved answers when opening a topic
	_load_answers_for_current_topic()

func _on_next_btn_pressed():
	if current_page_index in page6_indices:
		match current_page_index:
			6:
				completed_topics["noun"] = true
				GameManager.complete_study_topic("literacy","noun")
				GameManager.add_diamonds(1)
			12:
				completed_topics["adjective"] = true
				GameManager.complete_study_topic("literacy","adjective")
				GameManager.add_diamonds(1)
			18:
				completed_topics["pronouns"] = true
				GameManager.complete_study_topic("literacy","pronouns")
				GameManager.add_diamonds(1)
			24:
				completed_topics["verb"] = true
				GameManager.complete_study_topic("literacy","verb")
				GameManager.add_diamonds(1)
			30:
				completed_topics["adverb"] = true
				GameManager.complete_study_topic("literacy","adverb")
				GameManager.add_diamonds(1)
			36:
				completed_topics["conjunction"] = true
				GameManager.complete_study_topic("literacy","adjective")
				GameManager.add_diamonds(1)
		_go_to_topic_buttons()
	elif current_page_index < page_list.size() - 1:
		current_page_index += 1
		update_page_navigation()

func _on_back_btn_pressed():
	if current_page_index in topic_first_pages and _from_topic_buttons:
		_go_to_topic_buttons()
	elif current_page_index > 0:
		current_page_index -= 1
		update_page_navigation()
	else:
		_go_to_topic_buttons()

# --- 5. REFLECTION ---
func _count_words(text: String) -> int:
	var count = 0
	for word in text.replace("\n", " ").split(" "):
		if word.strip_edges() != "":
			count += 1
	return count

func _check_reflection_inputs() -> void:
	var current_page = page_list[current_page_index]
	var learned = current_page.get_node_or_null("LearnedInput")
	var surprised = current_page.get_node_or_null("SurprisedInput")
	var next_btn = current_page.get_node_or_null("NextBtn")

	if learned == null or surprised == null or next_btn == null:
		return

	var learned_words = _count_words(learned.text)
	var surprised_words = _count_words(surprised.text)

	if learned_words >= 10 and surprised_words >= 10:
		next_btn.show()
		next_btn.disabled = false
		next_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		next_btn.hide()

func _on_learned_input_text_changed() -> void:
	if current_page_index in page6_indices:
		# ✅ NEW: Save the answer as the player types
		var page = page_list[current_page_index]
		var learned = page.get_node_or_null("LearnedInput")
		if learned:
			GameManager.save_study_answer(_get_topic_key(current_page_index), "answer1", learned.text)
		_check_reflection_inputs()

func _on_surprised_input_text_changed() -> void:
	if current_page_index in page6_indices:
		# ✅ NEW: Save the answer as the player types
		var page = page_list[current_page_index]
		var surprised = page.get_node_or_null("SurprisedInput")
		if surprised:
			GameManager.save_study_answer(_get_topic_key(current_page_index), "answer2", surprised.text)
		_check_reflection_inputs()

# --- ✅ NEW: SAVE/LOAD HELPERS ---

# Returns the GameManager key for a given reflection page index
func _get_topic_key(index: int) -> String:
	match index:
		6:  return "literacy_noun"
		12: return "literacy_adjective"
		18: return "literacy_pronouns"
		24: return "literacy_verb"
		30: return "literacy_adverb"
		36: return "literacy_conjunction"
	return ""

# Finds the reflection page for the current topic and restores saved text
func _load_answers_for_current_topic():
	# Find the reflection page (page6) that belongs to the current topic
	var reflection_index = -1
	for i in page6_indices:
		if current_page_index <= i:
			reflection_index = i
			break
	if reflection_index == -1:
		return
	var page = page_list[reflection_index]
	if page == null:
		return
	var topic = _get_topic_key(reflection_index)
	var learned = page.get_node_or_null("LearnedInput")
	var surprised = page.get_node_or_null("SurprisedInput")
	if learned:
		learned.text = GameManager.get_study_answer(topic, "answer1")
	if surprised:
		surprised.text = GameManager.get_study_answer(topic, "answer2")

# --- 6. HOVER EFFECTS ---
func _on_any_btn_mouse_entered(btn: Control) -> void:
	if btn is BaseButton and (btn as BaseButton).disabled:
		return
	btn.self_modulate = Color(1.3, 1.3, 1.0)

func _on_any_btn_mouse_exited(btn: Control) -> void:
	btn.self_modulate = Color(1.0, 1.0, 1.0)

func _topic_hover(node_name: String, is_hovering: bool) -> void:
	var btn = topic_screen.get_node_or_null(node_name)
	if btn:
		btn.self_modulate = Color(1.3, 1.3, 1.0) if is_hovering else Color(1.0, 1.0, 1.0)

func _on_noun_btn_mouse_entered(): _topic_hover("NounBtn", true)
func _on_noun_btn_mouse_exited(): _topic_hover("NounBtn", false)
func _on_adjectives_btn_mouse_entered(): _topic_hover("AdjectivesBtn", true)
func _on_adjectives_btn_mouse_exited(): _topic_hover("AdjectivesBtn", false)
func _on_pronouns_btn_mouse_entered(): _topic_hover("PronounsBtn", true)
func _on_pronouns_btn_mouse_exited(): _topic_hover("PronounsBtn", false)
func _on_verb_btn_mouse_entered(): _topic_hover("VerbBtn", true)
func _on_verb_btn_mouse_exited(): _topic_hover("VerbBtn", false)
func _on_adverb_btn_mouse_entered(): _topic_hover("AdverbBtn", true)
func _on_adverb_btn_mouse_exited(): _topic_hover("AdverbBtn", false)
func _on_conjunction_btn_mouse_entered(): _topic_hover("ConjunctionBtn", true)
func _on_conjunction_btn_mouse_exited(): _topic_hover("ConjunctionBtn", false)

# --- 7. EXITS ---
func _on_cancel_btn_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/FableIsland/literacy_intro.tscn")

# --- 8. TOPIC BUTTONS ---
func _on_noun_btn_pressed() -> void:
	_from_topic_buttons = true
	_pending_topic_index = 1
	current_page_index = 1
	_go_to_book()

func _on_adjectives_btn_pressed() -> void:
	_from_topic_buttons = true
	_pending_topic_index = 7
	current_page_index = 7
	_go_to_book()

func _on_pronouns_btn_pressed() -> void:
	_from_topic_buttons = true
	_pending_topic_index = 13
	current_page_index = 13
	_go_to_book()

func _on_verb_btn_pressed() -> void:
	_from_topic_buttons = true
	_pending_topic_index = 19
	current_page_index = 19
	_go_to_book()

func _on_adverb_btn_pressed() -> void:
	_from_topic_buttons = true
	_pending_topic_index = 25
	current_page_index = 25
	_go_to_book()

func _on_conjunction_btn_pressed() -> void:
	_from_topic_buttons = true
	_pending_topic_index = 31
	current_page_index = 31
	_go_to_book()

func _on_texture_button_pressed() -> void:
	GameManager.load_scene("res://Assets/Scene/StudySession/Zypheria/study_session_main.tscn")
