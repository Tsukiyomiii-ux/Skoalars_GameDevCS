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
	AudioManager.play_music(preload("res://Assets/Audio/GameBG.wav"))
	if player and goal:
		total_distance = player.global_position.distance_to(goal.global_position)
	
	if mission_scroll:
		mission_scroll.show()
	
	is_timer_active = true
	GameManager.set_current_island("island_1")
	GameManager.set_allowed_skills(["add_time", "freeze_time", "hint"])  # ✅ Add hint
	GameManager.hint_requested.connect(_on_hint_used)  # ✅ Add this
	GameManager.freeze_requested.connect(_on_freeze_used)
	GameManager.add_time_requested.connect(_on_add_time_used)
	GameManager.settings_opened.connect(_on_settings_opened)  # ✅ Add this
	GameManager.settings_closed.connect(_on_settings_closed)
	await get_tree().create_timer(0.1).timeout
	GameManager.update_skill_button_states()


func _on_hint_used():
	if is_game_over: return
	
	# Create a canvas item to draw the arrow
	var arrow = Sprite2D.new()
	arrow.z_index = 100
	
	# Create a simple arrow texture using a polygon
	var arrow_mesh = MeshInstance2D.new()
	add_child(arrow_mesh)
	
	# Use a Label with an arrow character and rotate it instead
	var arrow_label = RichTextLabel.new()
	arrow_label.text = "➤"
	arrow_label.add_theme_font_size_override("normal_font_size", 64)
	arrow_label.size = Vector2(80, 80)
	arrow_label.z_index = 100
	arrow_label.modulate = Color(1, 1, 0)  # Yellow
	add_child(arrow_label)
	
	# Position above player
	arrow_label.global_position = player.global_position + Vector2(-40, -100)
	arrow_label.pivot_offset = Vector2(40, 40)  # Rotate from center
	
	# Calculate EXACT angle to the book
	var direction = goal.global_position - player.global_position
	var angle_deg = rad_to_deg(direction.angle())
	arrow_label.rotation_degrees = angle_deg
	
	# Pulse animation
	var tween = create_tween().set_loops(6)
	tween.tween_property(arrow_label, "scale", Vector2(1.3, 1.3), 0.3)
	tween.chain().tween_property(arrow_label, "scale", Vector2(1.0, 1.0), 0.3)
	
	# Fade out and remove after 3 seconds
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(arrow_label):
		var fade = create_tween()
		fade.tween_property(arrow_label, "modulate:a", 0.0, 0.5)
		fade.tween_callback(arrow_label.queue_free)

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

func _on_settings_opened():
	if has_node("CanvasLayer"):
		$CanvasLayer.hide()

func _on_settings_closed():
	if has_node("CanvasLayer") and not is_game_over:
		$CanvasLayer.show()

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
		
	
	
