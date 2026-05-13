extends Control

# --- POPUP SCRIPT ---
@export var open_cont: VBoxContainer
@export var volume_cont: VBoxContainer
@export var bottom_cont: VBoxContainer
@export var quest_Cont: NinePatchRect
@export var close_cont: VBoxContainer
@export var reward_btn_cont: HBoxContainer
@onready var reward_cont = $reward_cont
@export var skip_btn: Button
@onready var anim = $AnimationPlayer
@onready var done_btn = $reward_cont/VBoxContainer/NinePatchRect/NinePatchRect2/done_btn
@export var finished_btn: Button
# --- QUEST UI (with null safety) ---
@onready var word_container = %WordContainer
@onready var clue_label = %ClueLabel
@onready var progress_label = %ProgressLabel
@onready var time_label = %TimeLabel
@onready var correct_banner = %CorrectBanner
@onready var wrong_banner = %WrongBanner

@onready var snd_correct = $SndCorrect
@onready var snd_wrong = $SndWrong
@onready var snd_level_start = %SndLevelStart
@onready var snd_ticking = %SndTicking

func can_use_hint() -> bool:
	return GameManager.has_skill("hint") and GameManager.spend_diamonds(5)

func can_freeze_time() -> bool:
	return GameManager.has_skill("freeze_time") and GameManager.spend_diamonds(10)

func can_add_time() -> bool:
	return GameManager.has_skill("add_time") and GameManager.spend_diamonds(8)

func can_skip_question() -> bool:
	return GameManager.has_skill("skip") and GameManager.spend_diamonds(15)

func _on_hint_skill_pressed():
	if can_use_hint():
		print("💡 Hint used!")

func _on_freeze_pressed():
	if can_freeze_time():
		is_timer_active = false
		print("⏸️ Time frozen!")

func _on_add_time_pressed():
	if can_add_time():
		time_left += 10
		print("⏱️ +10s added!")

func _on_skip_question_pressed():
	if can_skip_question():
		correct_answers += 1
		start_new_word()
		print("⏭️ Skipped!")

func complete_level():
	GameManager.add_diamonds(25)

# --- STATES ---
var step := 0
var tutorial_done := false
var reward_shown := false
var is_quest_mode := false

# --- QUEST VARIABLES ---
const MY_FONT = preload("res://Assets/Sprite/FABLE ISLE/Level2/ARCADECLASSIC.TTF")
const TILE_IMAGE = preload("res://Assets/Sprite/FABLE ISLE/Level2/LetterTile.png")

var next_scene = "res://Assets/Scene/main_island.tscn"
var all_story_words = [
	"BOY", "APPLE", "RED", "DOG", "CAT",
	"BLUE", "PINK", "SUN", "MOON", "PLAY"
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

func _ready() -> void:
	AudioManager.play_music(preload("res://Assets/Audio/SoftEng_BG1.wav"))
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not GameManager.cutscene_played:
		$Popup/Exit/VBoxContainer2/VBoxContainer/HBoxContainer2/NinePatchRect4/study_btn.disabled = true       # grays it out and blocks clicks
		$Popup/Exit/VBoxContainer2/VBoxContainer/HBoxContainer2/NinePatchRect4/study_btn.modulate.a = 0.4      # optional: make it look faded
	
	# Done visible, skip hidden at start
	safe_set_visible(finished_btn, GameManager.tutorial_completed)
	safe_set_visible(skip_btn, false)
	
	if snd_level_start and is_instance_valid(snd_level_start):
		snd_level_start.play()
	
	print("🎮 Tutorial mode started - Done button visible")

func safe_set_visible(node: Node, visible: bool):
	if node and is_instance_valid(node):
		node.visible = visible

func safe_toggle_visibility(node: Node):
	if node and is_instance_valid(node):
		node.visible = !node.visible

func play():
	get_tree().paused = false

func pause():
	get_tree().paused = true

# TUTORIAL INPUT
func on_tutorial_finished():
	print("✅ on_tutorial_finished called")
	tutorial_done = true
	GameManager.tutorial_completed = true
	GameManager.save_game()
	safe_set_visible(finished_btn, true)

func _unhandled_input(event):
	if tutorial_done:
		return
	if event.is_action_pressed("ui_down"):
		step += 1
		print("Tutorial step:", step)
		if step >= 3:
			tutorial_done = true
			print("✅ Tutorial complete!")

# Show quest with blur + hide buttons
func show_quest_with_blur():
	is_quest_mode = true
	
	safe_set_visible(quest_Cont, true)
	safe_set_visible(word_container, true)
	safe_set_visible(clue_label, true)
	safe_set_visible(progress_label, true)
	safe_set_visible(time_label, true)
	safe_set_visible(open_cont, false)
	safe_set_visible(volume_cont, false)
	safe_set_visible(reward_btn_cont, false)
	safe_set_visible(close_cont, false)
	
	# Swap buttons
	safe_set_visible(finished_btn, false)
	safe_set_visible(skip_btn, false)
	
	$AnimationPlayer.play_backwards("blur")
	setup_word_pool()
	start_new_word()

func show_reward():
	is_game_finished = true
	is_timer_active = false
	is_quest_mode = false

	if snd_ticking and is_instance_valid(snd_ticking):
		snd_ticking.stop()

	safe_set_visible(quest_Cont, false)
	safe_set_visible(close_cont, false)
	safe_set_visible(bottom_cont, false)
	safe_set_visible(word_container, false)
	safe_set_visible(clue_label, false)
	safe_set_visible(progress_label, false)
	safe_set_visible(time_label, false)
	safe_set_visible(reward_cont, true)
	safe_set_visible(reward_btn_cont, false)
	safe_set_visible(skip_btn, false)
	safe_set_visible(done_btn, true)
	safe_set_visible(finished_btn, true)
	$AnimationPlayer.play_backwards("blur")

# --- QUEST FUNCTIONS ---
func _process(delta):
		# ✅ Check if tutorial just completed
	if not tutorial_done and GameManager.tutorial_completed:
		tutorial_done = true
		safe_set_visible(finished_btn, true)
		print("✅ Done button shown via GameManager")
	
	if is_timer_active and not is_game_finished and tutorial_done:
		if time_left > 0:
			time_left -= delta
			if time_label and is_instance_valid(time_label):
				time_label.text = str(ceil(time_left))
			if time_left <= 5.0 and snd_ticking and is_instance_valid(snd_ticking) and not snd_ticking.playing:
				snd_ticking.play()
		else:
			is_timer_active = false
			if snd_ticking and is_instance_valid(snd_ticking):
				snd_ticking.stop()
			on_time_out()

func setup_word_pool():
	randomize()
	var temp_list = all_story_words.duplicate()
	temp_list.shuffle()
	current_session_words = temp_list.slice(0, 2)
	current_word_index = 0

func start_new_word():
	if progress_label and is_instance_valid(progress_label):
		progress_label.text = str(correct_answers) + "/2"
	if word_container and is_instance_valid(word_container):
		for child in word_container.get_children():
			child.queue_free()
	if correct_answers >= 2:
		show_reward()
		return
	
	# ← Add this check
	if current_word_index >= current_session_words.size():
		current_word_index = 0
		setup_word_pool()
	
	target_word = current_session_words[current_word_index]
	time_left = 15.0
	setup_display_array()
	update_clue_text()
	create_letter_buttons()

func setup_display_array():
	current_display_array.clear()
	var length = target_word.length()
	for i in range(length):
		if target_word[i] == " ":
			current_display_array.append(" ")
			continue
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
	if not word_container or not is_instance_valid(word_container):
		return
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
	if clue_label and is_instance_valid(clue_label):
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
				check_answer_after_delay()
			break

func check_answer_after_delay():
	await get_tree().create_timer(0.3).timeout
	check_answer()

func on_time_out():
	if snd_wrong and is_instance_valid(snd_wrong):
		snd_wrong.play()
	get_tree().create_timer(0.5).timeout.connect(func():
		current_word_index += 1
		if current_word_index >= current_session_words.size():
			current_word_index = 0
		start_new_word()
	)

func show_correct_banner():
	if correct_banner and is_instance_valid(correct_banner):
		correct_banner.visible = true
		await get_tree().create_timer(0.8).timeout
		correct_banner.visible = false

func show_wrong_banner():
	if wrong_banner and is_instance_valid(wrong_banner):
		wrong_banner.visible = true
		wrong_banner.move_to_front()
		await get_tree().create_timer(0.8).timeout
		wrong_banner.visible = false

func check_answer():
	var built_word = "".join(current_display_array)
	if built_word == target_word:
		if snd_ticking and is_instance_valid(snd_ticking):
			snd_ticking.stop()
		if snd_correct and is_instance_valid(snd_correct):
			snd_correct.play()
			show_correct_banner()
		correct_answers += 1
		current_word_index += 1
		await get_tree().create_timer(0.8).timeout
		start_new_word()
	else:
		if snd_wrong and is_instance_valid(snd_wrong):
			snd_wrong.play()
			show_wrong_banner()
		shake_text()
		get_tree().create_timer(0.4).timeout.connect(reset_only_blanks)

func reset_only_blanks():
	setup_display_array()
	update_clue_text()

func shake_text():
	if not clue_label or not is_instance_valid(clue_label):
		return
	var tween = create_tween()
	var pos = clue_label.position
	tween.tween_property(clue_label, "position", pos + Vector2(15, 0), 0.05)
	tween.tween_property(clue_label, "position", pos - Vector2(15, 0), 0.05)
	tween.tween_property(clue_label, "position", pos + Vector2(15, 0), 0.05)
	tween.tween_property(clue_label, "position", pos, 0.05)
	if snd_ticking and is_instance_valid(snd_ticking):
		snd_ticking.stop()

# --- UI BUTTONS ---
func _on_home_btn_pressed() -> void:
	play()
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_menu.tscn")

func _on_done_btn_pressed() -> void:
	tutorial_done = true
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_island.tscn")

func _on_skip_btn_pressed() -> void:
	show_reward()
	print("⏭️ Quest skipped - Showing reward!")

func _on_finished_btn_pressed() -> void:
	tutorial_done = true
	show_quest_with_blur()
	print("✅ Finished pressed - Quest starting!")

func _on_mute_btn_pressed():
	AudioManager.toggle_mute()
	%mute_btn.visible = false
	%unmute_btn.visible = true

func _on_unmute_btn_pressed():
	AudioManager.toggle_mute()
	%mute_btn.visible = true
	%unmute_btn.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _on_shop_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/skillShop.tscn")

func _on_settings_btn_pressed() -> void:
	safe_toggle_visibility(open_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	pause()
	if anim and is_instance_valid(anim):
		anim.play_backwards("blur")

func _on_quit_btn_pressed() -> void:
	play()
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_menu.tscn")

func _on_play_btn_pressed() -> void:
	play()
	if anim and is_instance_valid(anim):
		anim.play("blur")
	safe_toggle_visibility(open_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)

func _on_volume_btn_pressed() -> void:
	safe_toggle_visibility(volume_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	if anim and is_instance_valid(anim):
		anim.play_backwards("blur")

func _on_ext_btn_pressed() -> void:
	safe_toggle_visibility(volume_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	if anim and is_instance_valid(anim):
		anim.play("blur")

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
