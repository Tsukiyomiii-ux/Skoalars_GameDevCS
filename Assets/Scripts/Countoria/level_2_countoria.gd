extends Node2D

# --- 1. Node References ---
@onready var question_label = $questionboard/question_text
@onready var answer_label = $CanvasLayer2/numboard/answer_board/answer_container/answer_text
@onready var timer_label = $timer/timerlabel
@onready var game_timer = $timer/gametimer
@onready var progress_bar = $progressbar_frame/textureprogressbar

# --- VIDEO NODE ---
@onready var video_player = $lvl2_ui_layer/dash_rescue 

# --- BASKET NODES ---
@onready var basket_node = $basket
@onready var basket_label = $basket/basket_counter

# --- AUDIO NODES ---
@onready var correct_audio = $correct_audio
@onready var wrong_audio = $wrong_audio
@onready var tapping_audio = $tapping_audio

# --- UI LAYER ---
@onready var ui_layer = $lvl2_ui_layer
@onready var blur_overlay = $lvl2_ui_layer/lvl2_bluroverlay
@onready var win_board = $CanvasLayer3/completion_board
@onready var lose_board = $lvl2_ui_layer/losing_board

# --- HOURGLASS REFERENCE ---
@onready var hourglass_anim = $lvl2_ui_layer/losing_board/hour_glass

# --- REWARD NODES --- fix these paths
@onready var wand_icon = $CanvasLayer3/completion_board/completion_bg/wand
@onready var gem_icon = $CanvasLayer3/completion_board/completion_bg/gem
@onready var key_icon = $CanvasLayer3/completion_board/completion_bg/key

# --- 2. Game Variables ---
var current_answer_string = ""
var correct_result = 0
var score = 0
var total_to_win = 10 
var fruit_options = ["Apples", "Oranges", "Bananas", "Bread", "Milk", "Carrots", "Potato"]
var game_over = false
var is_frozen: bool = false
var numboard_ref: Node2D = null

# ✅ NEW: Operation pool — all 4 operations included
var operations = ["addition", "subtraction", "multiplication", "division"]

func _ready():
	AudioManager.play_music(preload("res://Assets/Audio/GameBG.wav"))
	win_board.hide()
	lose_board.hide()
	blur_overlay.hide()
	$CanvasLayer3/completion_board/back_button.disabled = true
	$CanvasLayer3/completion_board/back_button.modulate = Color(0.5,0.5,0.5)
	$CanvasLayer3/completion_board/completion_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# --- VIDEO SETUP ---
	if video_player:
		video_player.hide()
		video_player.expand = true
		video_player.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		if not video_player.finished.is_connected(_on_dash_rescue_finished):
			video_player.finished.connect(_on_dash_rescue_finished)

	if progress_bar:
		progress_bar.max_value = total_to_win
		progress_bar.value = 0

	if wand_icon: wand_icon.pivot_offset = wand_icon.size / 2
	if gem_icon: gem_icon.pivot_offset = gem_icon.size / 2
	if key_icon: key_icon.pivot_offset = key_icon.size / 2

	setup_numpad_buttons()
	setup_board_buttons()
	update_basket_ui()

	if game_timer and not game_timer.timeout.is_connected(_on_timer_timeout):
		game_timer.timeout.connect(_on_timer_timeout)

	game_timer.one_shot = true
	game_timer.start(90)

	generate_math_question()
	
	GameManager.set_current_island("island_2.5")
	GameManager.set_allowed_skills(["hint", "freeze_time", "add_time", "skip"])
	GameManager.hint_requested.connect(_on_hint_used)
	GameManager.freeze_requested.connect(_on_freeze_used)
	GameManager.add_time_requested.connect(_on_add_time_used)
	GameManager.skip_requested.connect(_on_skip_used)
	await get_tree().create_timer(0.1).timeout
	GameManager.update_skill_button_states()
	
	
	# Move numboard to high priority CanvasLayer
	var cl = CanvasLayer.new()
	cl.layer = 200
	get_tree().root.add_child(cl)
	GameManager.register_cleanup_node(cl)
	var numboard = $CanvasLayer2/numboard
	var original_pos = numboard.global_position
	numboard.get_parent().remove_child(numboard)
	cl.add_child(numboard)
	numboard.global_position = original_pos
	numboard_ref = numboard  # ← save the reference here


# --- SKILL FUNCTIONS ---
func _on_hint_used():
	if game_over: return
	
	# Fill in the answer
	current_answer_string = str(correct_result)
	answer_label.text = current_answer_string
	
	# Get answer_board via numboard_ref since it was moved dynamically
	if not numboard_ref or not is_instance_valid(numboard_ref): return
	var answer_board = numboard_ref.get_node_or_null("answer_board")
	if not answer_board: return
	
	# Set pivot to center for scaling
	answer_board.scale = Vector2(1.0, 1.0)
	
	# Pop + golden shine effect
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale pop
	tween.tween_property(answer_board, "scale", Vector2(1.4, 1.4), 0.15).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_property(answer_board, "scale", Vector2(1.0, 1.0), 0.2)
	
	# Flash golden
	tween.tween_property(answer_board, "modulate", Color(2.0, 1.8, 0.2), 0.15)
	tween.chain().tween_property(answer_board, "modulate", Color(1, 1, 1), 0.4)

func _on_freeze_used():
	is_frozen = true
	game_timer.paused = true
	await get_tree().create_timer(10.0).timeout
	game_timer.paused = false
	is_frozen = false

func _on_add_time_used():
	var current = game_timer.time_left
	game_timer.stop()
	game_timer.start(current + 10.0)

func _on_skip_used():
	if game_over: return
	if correct_audio: correct_audio.play()
	score += 1
	update_basket_ui()
	if progress_bar: progress_bar.value = score
	current_answer_string = ""
	answer_label.text = ""
	if score >= total_to_win:
		win_level()
	else:
		generate_math_question()

# --- 3. UI Logic ---
func setup_board_buttons():
	var win_back = $CanvasLayer3/completion_board/back_button
	var rewards_btn = $CanvasLayer3/completion_board/rewards_button  # not in completion_bg

	if win_back:
		apply_hover_effect(win_back)
		if not win_back.pressed.is_connected(_on_rescue_pressed):
			win_back.pressed.connect(_on_rescue_pressed)

	if rewards_btn:
		apply_hover_effect(rewards_btn)
		if not rewards_btn.pressed.is_connected(_on_rewards_claimed):
			rewards_btn.pressed.connect(_on_rewards_claimed)

	var try_again = lose_board.get_node_or_null("tryagain_btn")
	var quit_btn = lose_board.get_node_or_null("quit_btn")

	if try_again:
		apply_hover_effect(try_again)
		if not try_again.pressed.is_connected(_on_reload_scene):
			try_again.pressed.connect(_on_reload_scene)

	if quit_btn:
		apply_hover_effect(quit_btn)
		if not quit_btn.pressed.is_connected(_on_menu_pressed):
			quit_btn.pressed.connect(_on_menu_pressed)

func _on_rewards_claimed():
	if tapping_audio: tapping_audio.play()
	GameManager.collect_island_reward("island_2.5")
	GameManager.collect_island_reward("island_2")
	GameManager.complete_minigame("island_2")
	
	var tween = create_tween().set_parallel(true)
	var icons = [wand_icon, gem_icon, key_icon]
	for icon in icons:
		if icon:
			tween.tween_property(icon, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.chain().tween_property(icon, "scale", Vector2.ONE, 0.2)

	# Enable back button after reward is claimed
	var btn = $CanvasLayer3/completion_board/back_button
	btn.disabled = false
	btn.modulate = Color(1, 1, 1)  # restore normal color

func _on_rescue_pressed():
	if video_player:
		win_board.hide()
		lose_board.hide()
		blur_overlay.hide()
		video_player.show()
		video_player.play()
		if tapping_audio: tapping_audio.play()

# --- 4. Game Logic ---
func _on_enter_pressed():
	if game_over or current_answer_string == "": return
	if int(current_answer_string) == correct_result:
		if correct_audio: correct_audio.play()
		score += 1
		update_basket_ui()
		if progress_bar: progress_bar.value = score
		current_answer_string = ""; answer_label.text = ""
		if score >= total_to_win:
			win_level()
		else:
			generate_math_question()
	else:
		if wrong_audio: wrong_audio.play()
		apply_time_penalty(2)
		if numboard_ref and is_instance_valid(numboard_ref):
			shake_node(numboard_ref.get_node_or_null("answer_board"))
		current_answer_string = ""; answer_label.text = ""

func _on_timer_timeout():
	if !game_over:
		lose_level()
		cleanup_numboard()
		if numboard_ref and is_instance_valid(numboard_ref):
			numboard_ref.hide()
		if ui_layer:
			$CanvasLayer/Skoalars.hide()

# ✅ UPDATED: generate_math_question now includes all 4 operations
func generate_math_question():
	if game_over: return
	current_answer_string = ""
	answer_label.text = ""
	var fruit = fruit_options.pick_random()
	var op = operations.pick_random()

	match op:
		"addition":
			var v1 = randi_range(1, 10)
			var v2 = randi_range(1, 10)
			correct_result = v1 + v2
			question_label.text = "%d %s + %d %s = ?" % [v1, fruit, v2, fruit]

		"subtraction":
			var v1 = randi_range(1, 10)
			var v2 = randi_range(1, 10)
			# Always subtract smaller from larger so result is never negative
			if v1 < v2:
				var t = v1; v1 = v2; v2 = t
			correct_result = v1 - v2
			question_label.text = "%d %s - %d %s = ?" % [v1, fruit, v2, fruit]

		"multiplication":
			# Keep numbers small so result stays manageable (max 5x5=25)
			var v1 = randi_range(1, 5)
			var v2 = randi_range(1, 5)
			correct_result = v1 * v2
			question_label.text = "%d %s × %d %s = ?" % [v1, fruit, v2, fruit]

		"division":
			# Generate a clean division: pick divisor and result first,
			# so the dividend always divides evenly (no remainders)
			var divisor = randi_range(1, 5)
			var result = randi_range(1, 5)
			var dividend = divisor * result
			correct_result = result
			question_label.text = "%d %s ÷ %d %s = ?" % [dividend, fruit, divisor, fruit]

func win_level():
	game_over = true
	game_timer.stop()
	if blur_overlay: blur_overlay.show()
	if win_board:
		win_board.show()
		animate_board(win_board)
		$CanvasLayer3/completion_board/back_button.show()
		$CanvasLayer3/completion_board/rewards_button.show()
		$CanvasLayer/Skoalars.hide()
		if numboard_ref and is_instance_valid(numboard_ref):
			numboard_ref.hide()

func lose_level():
	game_over = true
	game_timer.stop()
	if blur_overlay: blur_overlay.show()
	if lose_board:
		lose_board.show()
		if hourglass_anim: hourglass_anim.play("default")
		animate_board(lose_board)

# --- 5. Helpers ---
func apply_hover_effect(btn: TextureButton):
	if !btn: return
	btn.pivot_offset = btn.size / 2
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	if not btn.mouse_entered.is_connected(_on_btn_hover_start.bind(btn)):
		btn.mouse_entered.connect(_on_btn_hover_start.bind(btn))
	if not btn.mouse_exited.is_connected(_on_btn_hover_end.bind(btn)):
		btn.mouse_exited.connect(_on_btn_hover_end.bind(btn))

func _on_btn_hover_start(btn):
	create_tween().tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)

func _on_btn_hover_end(btn):
	create_tween().tween_property(btn, "scale", Vector2.ONE, 0.1)

func _process(_delta):
	if !game_over and game_timer and timer_label and not is_frozen:
		var time_left = game_timer.time_left
		var mins = int(time_left / 60)
		var secs = int(time_left) % 60
		timer_label.text = "%02d:%02d" % [mins, secs]

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if tapping_audio: tapping_audio.play()

func update_basket_ui():
	if basket_label: basket_label.text = str(score) + " / " + str(total_to_win)

func apply_time_penalty(amount: float):
	var current_time = game_timer.time_left
	game_timer.stop()
	game_timer.start(max(0.1, current_time - amount))

func animate_board(board):
	board.pivot_offset = board.size / 2
	board.scale = Vector2(0.5, 0.5)
	create_tween().tween_property(board, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)

func setup_numpad_buttons():
	var pad = $CanvasLayer2/numboard/numpad_board
	if not pad: return
	for i in range(10):
		var btn = pad.get_node_or_null(str(i))
		if btn:
			if not btn.pressed.is_connected(_on_num_pressed):
				btn.pressed.connect(_on_num_pressed.bind(str(i)))
			apply_hover_effect(btn)
	var enter_btn = pad.get_node_or_null("enter_button")
	var del_btn = pad.get_node_or_null("back_button")
	if enter_btn:
		if not enter_btn.pressed.is_connected(_on_enter_pressed): enter_btn.pressed.connect(_on_enter_pressed)
		apply_hover_effect(enter_btn)
	if del_btn:
		if not del_btn.pressed.is_connected(_on_back_pressed): del_btn.pressed.connect(_on_back_pressed)
		apply_hover_effect(del_btn)

func _on_num_pressed(digit: String):
	if game_over: return
	if current_answer_string.length() < 3:
		current_answer_string += digit
		answer_label.text = current_answer_string

func _on_back_pressed():
	if current_answer_string.length() > 0:
		current_answer_string = current_answer_string.left(-1)
		answer_label.text = current_answer_string

func cleanup_numboard():
	if numboard_ref and is_instance_valid(numboard_ref):
		var parent = numboard_ref.get_parent()
		if parent and is_instance_valid(parent):
			parent.queue_free()  # Frees the entire dynamic CanvasLayer

func shake_node(target_node: Node):
	if !target_node: return
	var op = target_node.position
	var t = create_tween()
	t.tween_property(target_node, "position:x", op.x + 8, 0.05)
	t.chain().tween_property(target_node, "position:x", op.x - 8, 0.05)
	t.chain().tween_property(target_node, "position:x", op.x, 0.05)

func _on_reload_scene(): 
	get_tree().reload_current_scene()
	GameManager.cleanup_persistent_nodes()
func _on_menu_pressed(): 
	GameManager.cleanup_persistent_nodes()
	get_tree().change_scene_to_file("res://Assets/Scene/Countoria/countoria.tscn")

# --- 6. FINAL REDIRECTION ---
func _on_dash_rescue_finished() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/mapSelector.tscn")
	GameManager.unlock_island("island_3")
	
