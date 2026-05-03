extends VBoxContainer

@onready var word_container = %WordContainer
@onready var clue_label = %ClueLabel
@onready var progress_label = %ProgressLabel
@onready var time_label = %TimeLabel
@onready var correct_banner = %CorrectBanner
@onready var wrong_banner = %WrongBanner

@onready var snd_correct = %SndCorrect
@onready var snd_wrong = %SndWrong
@onready var snd_level_start = %SndLevelStart
@onready var snd_ticking = %SndTicking

var reward_shown := false

# --- ASSETS ---
const MY_FONT = preload("res://Assets/Sprite/FABLE ISLE/Level2/ARCADECLASSIC.TTF")
const TILE_IMAGE = preload("res://Assets/Sprite/FABLE ISLE/Level2/LetterTile.png")

# --- NEXT SCENE ---
var next_scene = "res://Assets/Scene/main_island.tscn" # change if needed

# --- VARIABLES ---
var all_story_words = [
	"BOY", "APPLE", "MAMA MO", "DOG", "CAT",
	"BLUE", "PINK", "SUN", "PIG", "PLAY"
]

var current_session_words = []
var current_word_index = 0
var target_word = ""
var current_display_array = []
var correct_answers = 0

# --- TIMER ---
var time_left: float = 15.0
var is_timer_active: bool = true
var is_game_finished: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	if is_instance_valid(snd_level_start):
		snd_level_start.play()

	setup_word_pool()
	start_new_word()

func _process(delta):
	if is_timer_active and not is_game_finished:
		if time_left > 0:
			time_left -= delta

			if time_label:
				time_label.text = str(ceil(time_left))

			if time_left <= 5.0 and is_instance_valid(snd_ticking):
				if not snd_ticking.playing:
					snd_ticking.play()
		else:
			is_timer_active = false

			if is_instance_valid(snd_ticking):
				snd_ticking.stop()

			on_time_out()

func setup_word_pool():
	randomize()
	var temp_list = all_story_words.duplicate()
	temp_list.shuffle()

	current_session_words = temp_list.slice(0, 2) # only 2 questions
	current_word_index = 0

func start_new_word():
	if progress_label:
		progress_label.text = str(correct_answers) + "/2"

	for child in word_container.get_children():
		child.queue_free()

	# after 2 correct answers, change scene
	if correct_answers >= 2:
		go_to_next_scene()
		return

	target_word = current_session_words[current_word_index]

	if is_timer_active:
		time_left = 15.0

	setup_display_array()
	update_clue_text()
	create_letter_buttons()

func setup_display_array():
	current_display_array.clear()
	var length = target_word.length()

	for i in range(length):
		# handle spaces
		if target_word[i] == " ":
			current_display_array.append(" ")
			continue

		# short words (3 letters or less)
		if length <= 3:
			if i == 0:
				current_display_array.append(target_word[i])
			else:
				current_display_array.append("_")
		else:
			if i == 0 or i >= length - 2 or i % 2 == 0:
				current_display_array.append(target_word[i])
			else:
				current_display_array.append("_")

func create_letter_buttons():
	var length = target_word.length()
	var pool = []

	for i in range(length):
		if current_display_array[i] == "_":
			pool.append(target_word[i])

	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	while pool.size() < 8:
		pool.append(alphabet[randi() % alphabet.length()])

	pool.shuffle()

	for letter_char in pool:
		var btn = Button.new()
		btn.flat = true
		btn.custom_minimum_size = Vector2(160, 160)

		btn.add_child(create_tile_visual(letter_char))
		word_container.add_child(btn)

		btn.pressed.connect(_on_letter_selected.bind(letter_char))

func create_tile_visual(letter_char):
	var tile = TextureRect.new()
	tile.texture = TILE_IMAGE
	tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var lbl = Label.new()
	lbl.text = letter_char
	lbl.add_theme_font_override("font", MY_FONT)
	lbl.add_theme_font_size_override("font_size", 90)
	lbl.add_theme_color_override("font_color", Color(0.36, 0.16, 0.08))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE

	tile.add_child(lbl)
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	return tile

func update_clue_text():
	if clue_label == null:
		return

	var text_to_show = ""

	for char in current_display_array:
		text_to_show += char + "  "

	clue_label.text = text_to_show.to_upper()

func _on_letter_selected(letter_char):
	for i in range(current_display_array.size()):
		if current_display_array[i] == "_":
			current_display_array[i] = letter_char
			update_clue_text()

			if "_" not in current_display_array:
				get_tree().create_timer(0.3).timeout.connect(check_answer)
			break

func on_time_out():
	if is_instance_valid(snd_wrong):
		snd_wrong.play()

	get_tree().create_timer(0.5).timeout.connect(func():
		current_word_index += 1

		if current_word_index >= current_session_words.size():
			current_word_index = 0

		start_new_word()
	)

func show_correct_banner():
	if correct_banner == null:
		return
	
	correct_banner.visible = true
	
	await get_tree().create_timer(0.8).timeout
	
	correct_banner.visible = false

func show_wrong_banner():
	if wrong_banner == null:
		return
	
	wrong_banner.visible = true
	wrong_banner.move_to_front() # 👈 makes sure it's visible on top
	
	await get_tree().create_timer(0.8).timeout
	
	wrong_banner.visible = false

func check_answer():
	var built_word = "".join(current_display_array)

	if built_word == target_word:
		if is_instance_valid(snd_ticking):
			snd_ticking.stop()

		if is_instance_valid(snd_correct):
			snd_correct.play()
			show_correct_banner()

		correct_answers += 1
		current_word_index += 1

		await get_tree().create_timer(0.8).timeout
		start_new_word()
	else:
		if is_instance_valid(snd_wrong):
			snd_wrong.play()
			show_wrong_banner()

		shake_text()
		get_tree().create_timer(0.4).timeout.connect(reset_only_blanks)

func reset_only_blanks():
	setup_display_array()
	update_clue_text()

func shake_text():
	if not clue_label:
		return

	var tween = create_tween()
	var pos = clue_label.position

	tween.tween_property(clue_label, "position", pos + Vector2(15, 0), 0.05)
	tween.tween_property(clue_label, "position", pos - Vector2(15, 0), 0.05)
	tween.tween_property(clue_label, "position", pos + Vector2(15, 0), 0.05)
	tween.tween_property(clue_label, "position", pos, 0.05)

func go_to_next_scene():
	is_game_finished = true
	is_timer_active = false

	if is_instance_valid(snd_ticking):
		snd_ticking.stop()

	var timer = Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	add_child(timer)
	timer.start()

	await timer.timeout

	get_tree().change_scene_to_file(next_scene)



func _input(event):
	if event.is_action_pressed("ui_text_backspace"):
		var length = target_word.length()

		for i in range(current_display_array.size() - 1, -1, -1):
			if target_word[i] == " ":
				continue

			if length > 3 and (i == 0 or i >= length - 2 or i % 2 == 0):
				continue

			if length <= 3 and i == 0:
				continue

			if current_display_array[i] != "_":
				current_display_array[i] = "_"
				update_clue_text()
				break
