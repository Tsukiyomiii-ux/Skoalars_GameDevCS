extends Node2D

# --- UI NODES ---
@onready var word_container = %WordContainer
@onready var clue_label = %ClueLabel
@onready var definition_label = %DefinitionLabel # The small hint label
@onready var progress_label = %ProgressLabel 
@onready var time_label = %TimeLabel 

# --- BOARD SCENES ---
var win_scene = preload("res://Assets/Scene/FableIsland/quest_complete_ui.tscn")
var lose_scene = preload("res://Assets/Scene/FableIsland/quest_incomplete_ui.tscn")

# --- AUDIO NODES ---
@onready var snd_correct = %SndCorrect
@onready var snd_wrong = %SndWrong
@onready var snd_victory = %SndVictory
@onready var snd_game_over = %SndGameOver
@onready var snd_level_start = %SndLevelStart
@onready var snd_ticking = %SndTicking

# --- ASSETS ---
const MY_FONT = preload("res://Assets/Sprite/FABLE ISLE/Level2/ARCADECLASSIC.TTF")
const TILE_IMAGE = preload("res://Assets/Sprite/FABLE ISLE/Level2/LetterTile.png") 

# --- DATA (UPDATED WORDS) ---
var word_list = [
	"FRIENDS", "FLOATING", "SPLIT", "GREEDY", "ROOTS", 
	"PLANTED", "WITHERED", "LUSH", "RIPE", "CLIMB", 
	"ANGRY", "STAKES", "REVENGE", "MORTAR", "DROWN", 
	"CLEVER", "ESCAPE", "DEFEATED", "CONFLICT", "THEME"
]

var hint_list = [
	"HINT:people who like each other", "HINT:staying on water", "HINT:to divide into parts", "HINT:wanting too much", "HINT:parts that grow underground",
	"HINT:put in soil to grow", "HINT:dried up and died", "HINT:full of healthy plants", "HINT:ready to eat", "HINT:to go up",
	"HINT:feeling mad", "HINT:sharp sticks", "HINT:getting back at someone", "HINT:a bowl for grinding", "HINT:die in water",
	"HINT:smart and quick", "HINT:to get away", "HINT:beaten or lost", "HINT:a struggle or problem", "HINT:main message"
]

# --- VARIABLES ---
var current_session_indices = [] 
var failed_indices = []  
var current_list_pos = 0
var target_word = ""
var current_display_array = [] 
var correct_answers = 0 

# --- TIMER ---
var time_left: float = 120.0 
var is_timer_active: bool = false
var is_game_finished: bool = false 

var letter_buttons = []

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS 
	if is_instance_valid(snd_level_start): snd_level_start.play()
	if definition_label: definition_label.hide()
	
	GameManager.set_current_island("island_1.2")
	GameManager.hint_requested.connect(_on_hint_used)
	GameManager.freeze_requested.connect(_on_freeze_used)
	GameManager.add_time_requested.connect(_on_add_time_used)
	GameManager.skip_requested.connect(_on_skip_used)
	
	GameManager.set_allowed_skills(["add_time", "freeze_time", "hint", "skip"])
	await get_tree().create_timer(0.1).timeout
	GameManager.update_skill_button_states()
	GameManager.settings_opened.connect(_on_settings_opened)
	GameManager.settings_closed.connect(_on_settings_closed)
	
	# Force all Control nodes above to not block input
	for node in get_tree().get_nodes_in_group(""):
		if node is Control and node != self:
			if node.mouse_filter == Control.MOUSE_FILTER_STOP:
				node.mouse_filter = Control.MOUSE_FILTER_PASS
	
	word_container.mouse_filter = Control.MOUSE_FILTER_STOP
	# ... rest of your _ready()
	# ... rest of your existing _ready() code
	
	# --- RESET TIMER ONLY ONCE HERE ---
	time_left = 120.0 
	is_timer_active = true 
	
	setup_word_pool() 
	start_new_word()

func _on_hint_used():
	# Reveals one hidden letter
	for i in range(current_display_array.size()):
		if current_display_array[i] == "_":
			current_display_array[i] = target_word[i]
			update_clue_text()
			# If no more blanks after hint, check the answer
			if "_" not in current_display_array:
				get_tree().create_timer(0.3).timeout.connect(check_answer)
			break

func _on_freeze_used():
	# Pauses timer for 10 seconds
	is_timer_active = false
	await get_tree().create_timer(10.0).timeout
	is_timer_active = true

func _on_add_time_used():
	# Adds 30 seconds to timer
	time_left += 10.0

func _on_skip_used():
	# Count skip as a correct answer and move to next word
	correct_answers += 1
	current_list_pos += 1
	if progress_label:
		progress_label.text = str(correct_answers) + "/10"
	start_new_word()	

func _process(delta):
	if is_timer_active and not is_game_finished:
		if time_left > 0:
			time_left -= delta
			var mins = int(time_left) / 60
			var secs = int(time_left) %  60
			if time_label: time_label.text = "%02d:%02d" % [mins, secs]
			if time_left <= 10.0 and is_instance_valid(snd_ticking):
				if not snd_ticking.playing: snd_ticking.play()
		else:
			is_timer_active = false
			if is_instance_valid(snd_ticking): snd_ticking.stop()
			on_time_out()

func _on_settings_opened():
	if has_node("CanvasLayer"):
		$CanvasLayer.hide()
	if word_container: word_container.hide()

func _on_settings_closed():
	if not is_game_finished:
		if has_node("CanvasLayer"):
			$CanvasLayer.show()
		if word_container: word_container.show()

func setup_word_pool():
	randomize() 
	var all_indices = range(word_list.size())
	all_indices.shuffle() 
	current_session_indices = all_indices.slice(0, 10)
	current_list_pos = 0

func start_new_word():
	if is_game_finished: return 
	
	if progress_label:
		progress_label.text = str(correct_answers) + "/10"
	
	for child in word_container.get_children():
		child.queue_free()
	
	if current_list_pos >= current_session_indices.size():
		end_game()
		return
		
	var idx = current_session_indices[current_list_pos]
	target_word = word_list[idx]
	
	# REMOVED: time_left = 60.0 (Don't put it here!)
	# REMOVED: is_timer_active = true (It's already running!)
	
	setup_display_array()
	update_clue_text()
	create_letter_buttons()

func setup_display_array():
	current_display_array.clear()
	var length = target_word.length()
	for i in range(length):
		if i == 0 or i >= length - 2 or i % 2 == 0:
			current_display_array.append(target_word[i])
		else:
			current_display_array.append("_")

func create_letter_buttons():
	letter_buttons.clear()
	var pool = []
	for i in range(target_word.length()):
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
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.z_index = 10  # ← force it to be on top
		btn.add_child(create_tile_visual(letter_char))
		word_container.add_child(btn)
		letter_buttons.append({"button": btn, "letter": letter_char})
		btn.pressed.connect(_on_letter_selected.bind(letter_char))

func create_tile_visual(letter_char):
	var tile = TextureRect.new()
	tile.texture = TILE_IMAGE
	tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
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
	if clue_label == null: return
	var text_to_show = ""
	for char in current_display_array:
		text_to_show += char + "  " 
	clue_label.text = text_to_show.to_upper()
	
	if definition_label:
		var idx = current_session_indices[current_list_pos]
		if idx in failed_indices:
			definition_label.text = hint_list[idx]
			definition_label.show()
		else:
			definition_label.hide()

func _on_letter_selected(letter_char):
	for i in range(current_display_array.size()):
		if current_display_array[i] == "_":
			current_display_array[i] = letter_char
			update_clue_text()
			if "_" not in current_display_array:
				get_tree().create_timer(0.3).timeout.connect(check_answer)
			break

func on_time_out():
	# When time is 0, the whole quest is over!
	is_timer_active = false
	is_game_finished = true
	print("Time is up! Quest Incomplete.")
	end_game()

func check_answer():
	var built_word = "".join(current_display_array)
	if built_word == target_word:
		if is_instance_valid(snd_ticking): snd_ticking.stop()
		if is_instance_valid(snd_correct): snd_correct.play()
		correct_answers += 1
		current_list_pos += 1
		start_new_word()
	else:
		handle_wrong_answer()

func handle_wrong_answer():
	if is_instance_valid(snd_wrong): snd_wrong.play()
	shake_text()
	var idx = current_session_indices[current_list_pos]
	if not idx in failed_indices: failed_indices.append(idx)
	var failed_idx = current_session_indices.pop_at(current_list_pos)
	current_session_indices.append(failed_idx) 
	get_tree().create_timer(0.5).timeout.connect(start_new_word)

func end_game():
	print("GAME OVER TRIGGERED")
	is_game_finished = true
	is_timer_active = false
	
	# THE FIX: Use the % sign because the node is a Unique Name
	var snd = get_node_or_null("%SndGameOver")
	if snd:
		snd.play()
	else:
		print("Still can't find SndGameOver even with %")
	
	# FORCED UI - Switching scenes entirely
	if correct_answers < 10:
		get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/quest_incomplete_ui.tscn")
	else:
		get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/quest_complete_ui.tscn")

func shake_text():
	if not clue_label: return
	var tween = create_tween()
	var pos = clue_label.position
	tween.tween_property(clue_label, "position", pos + Vector2(15, 0), 0.05)
	tween.tween_property(clue_label, "position", pos - Vector2(15, 0), 0.05)
	tween.tween_property(clue_label, "position", pos, 0.05)
