extends Node2D

# --- UI NODES ---
@onready var player = $Skoalars
@onready var goal = $MagicBook
@onready var mission_scroll = $CanvasLayer/MissionScroll 
@onready var time_label = $CanvasLayer/TimeLabel
@onready var progress_bar = $CanvasLayer/TextureProgressBar

# --- AUDIO NODES ---
@onready var snd_victory = $SndVictory
@onready var snd_game_over = $SndGameOver
@onready var snd_tick = $SndTick

# --- VARIABLES ---
var total_distance: float
var time_left: float = 120.0 
var is_game_over: bool = false 
var is_timer_active: bool = false 
var is_ticking_playing: bool = false 
var is_game_finished = false

func _ready():
	if player and goal:
		total_distance = player.global_position.distance_to(goal.global_position)
	
	if mission_scroll:
		mission_scroll.show()
	
	is_timer_active = true
	GameManager.set_current_island("island_1")
	GameManager.set_allowed_skills(["add_time", "freeze_time"])
	GameManager.freeze_requested.connect(_on_freeze_used)
	GameManager.add_time_requested.connect(_on_add_time_used)
	await get_tree().create_timer(0.1).timeout
	GameManager.update_skill_button_states()

func _on_freeze_used():
	# Pauses timer for 10 seconds
	is_timer_active = false
	await get_tree().create_timer(10.0).timeout
	is_timer_active = true

func _on_add_time_used():
	# Adds 30 seconds to timer
	time_left += 10.0


func _process(delta):
	if is_game_over or not is_timer_active:
		return 

	# --- TIMER & SOUND LOGIC ---
	if time_left > 0:
		time_left -= delta
		update_timer_display()
		# Start ticking at 10 seconds
		if time_left <= 10.0 and not is_ticking_playing:
			if is_instance_valid(snd_tick):
				snd_tick.play()
				is_ticking_playing = true
				print("DEBUG: Ticking started!")
	else:
		game_over()

	# --- PROGRESS BAR LOGIC ---
	if player and goal and progress_bar:
		var current_dist = player.global_position.distance_to(goal.global_position)
		var progress = (1.0 - (current_dist / total_distance)) * 100
		progress_bar.value = clamp(progress, 0, 100)

func update_timer_display():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	if time_label:
		time_label.text = "%02d:%02d" % [minutes, seconds]

func _on_magic_book_body_entered(body):
	if body == player and not is_game_over:
		is_game_over = true
		is_timer_active = false
		
		# Stop the ticking (We still want this to stop!)
		if snd_tick: 
			snd_tick.stop()
		
		# Don't play snd_victory here anymore! 
		# Just change the scene immediately.
		get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/reward_screen.tscn")
		Global.target_level = "res://Assets/Scene/FableIsland/level_2_spelling_quest.tscn"
	
	

func game_over():
	# 1. STOP THE CLOCK SOUND IMMEDIATELY
	is_timer_active = false
	if is_instance_valid(snd_tick):
			snd_tick.stop()
	
	# 2. HIDE EVERYTHING (Using your exact Level 1 names)
	if has_node("%Label"): %Label.hide()
	if has_node("%TextureRect"): %TextureRect.hide()
	if has_node("%TimeLabel"): %TimeLabel.hide()
	if has_node("%ClockIcon"): %ClockIcon.hide()
	if has_node("%TextureProgressBar"): %TextureProgressBar.hide()
	if has_node("%TextureRect2"): %TextureRect2.hide()
	
	# 3. SHOW THE BOARD AND PLAY THE LOST SOUND
	if has_node("%GameOverUI"):
		%GameOverUI.show()
		# Look for the sound node in your Level 1 tree
		if has_node("SndGameOver"):
			$SndGameOver.play()
		
	
	
