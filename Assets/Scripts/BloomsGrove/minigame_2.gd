extends Node2D

var trash_list = [
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Apple.png"), "type": "bio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Banana.png"), "type": "bio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Coconutshell.png"), "type": "bio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Eggshell.png"), "type": "bio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Friedchickenbones.png"), "type": "bio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Leaves.png"), "type": "bio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Twig.png"), "type": "bio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Can.png"), "type": "recycle"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Glassbottle.png"), "type": "recycle"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Plasticbottle.png"), "type": "recycle"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Tincan.png"), "type": "recycle"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Tunacan.png"), "type": "recycle"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Newspaper.png"), "type": "recycle"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Cardboard.png"), "type": "recycle"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Chipswrapper.png"), "type": "nonbio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Plasticbag.png"), "type": "nonbio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Styrofoam.png"), "type": "nonbio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Lightbulb.png"), "type": "nonbio"},
	{"texture": preload("res://Assets/Bloom Game 1/New Assets/Game 2 BG/Trash/Brokenglass.png"), "type": "nonbio"}
]

var score = 0
var game_active = false
var time_left = 60.0 
var failed_items = [] 

@onready var time_label = $Timer/TimerText
@onready var mission_label = $Mission/VBoxContainer/MissionText
@onready var clue_label = $Holder/Clue 
@onready var progress_label = $Progress/ProgressText
@onready var trash_holder = $Holder 

# Popup References
@onready var win_popup_bg = $ColorRect
@onready var popup_sprite = $ColorRect/Popup
@onready var lose_popup_bg = $ColorRect2 
@onready var lose_popup_holder = $ColorRect2/Over
@onready var hourglass_anim = $ColorRect2/Over/Hourglass 
@onready var rescue_video = $RescueVideo 

@onready var sfx_correct = $SfxCorrect
@onready var sfx_wrong = $SfxWrong
@onready var bin_nodes = [$Bin_bio, $Bin_non, $Bin_rec]

const ORIGINAL_MISSION = "Become a Recycling Hero! Drag the trash into the right bins to clean up the park.\n\nBe quick—you have 1 minute to sort everything! Can you turn the Grove into a blooming paradise?"

func _ready():
	randomize()
	trash_list.shuffle()
	mission_label.text = ORIGINAL_MISSION
	clue_label.text = "" 
	
	progress_label.text = "0 / 10"
	time_label.text = "1:00"
	trash_holder.visible = false
	win_popup_bg.hide()
	lose_popup_bg.hide()
	
	# SETUP VIDEO SIZE AND POSITION VIA CODE
	setup_rescue_video()
	rescue_video.hide()
	
	rescue_video.finished.connect(_on_rescue_video_finished)
	start_countdown()

func setup_rescue_video():
	# This overrides the locked Inspector values (1920x1080 and 0.7 scale)
	rescue_video.expand = true # Ensures the video fills the node area
	rescue_video.anchor_right = 1
	rescue_video.anchor_bottom = 1
	rescue_video.offset_right = 0
	rescue_video.offset_bottom = 0
	rescue_video.position = Vector2.ZERO
	rescue_video.scale = Vector2(1, 1)
	# Force size to your project resolution
	rescue_video.size = get_viewport_rect().size 

func start_countdown():
	var countdown = 10
	while countdown > 0:
		mission_label.text = "Starting in... " + str(countdown)
		await get_tree().create_timer(1.0).timeout
		countdown -= 1
	
	mission_label.text = ORIGINAL_MISSION
	trash_holder.visible = true 
	game_active = true
	spawn_trash()

func _process(delta):
	if game_active and time_left > 0:
		time_left -= delta
		var mins = floor(time_left / 60)
		var secs = int(time_left) % 60
		time_label.text = str(mins) + ":" + str(secs).pad_zeros(2)
		
		if time_left <= 0:
			time_left = 0
			game_over_lose()

func spawn_trash():
	if score >= 10:
		show_win_popup()
		return
	
	for child in trash_holder.get_children():
		if child is Area2D: 
			child.queue_free()
		
	var trash_scene = preload("res://Assets/Scene/Trash.tscn")
	var new_trash = trash_scene.instantiate()
	var data = trash_list[0]
	
	trash_holder.add_child(new_trash)
	new_trash.position = Vector2(trash_holder.size.x / 2, trash_holder.size.y / 2)
	new_trash.get_node("Sprite2D").texture = data["texture"]
	new_trash.type = data["type"]
	
	if data in failed_items:
		match data["type"]:
			"bio": clue_label.text = "Hint: I was once part of something living. I can rot and help plants grow!"
			"recycle": clue_label.text = "Hint: I am tough and sturdy. If you send me away, I can become a brand new bottle or can!"
			"nonbio": clue_label.text = "Hint: I don't rot and I can't be remade. I have to be stored away forever."
	else:
		clue_label.text = "" 

func update_score():
	sfx_correct.play()
	score += 1
	progress_label.text = str(score) + " / 10"
	trash_list.remove_at(0)
	
	if score >= 10:
		show_win_popup()
	else:
		spawn_trash()

func handle_wrong_answer():
	sfx_wrong.play()
	var failed_data = trash_list[0]
	if not failed_data in failed_items:
		failed_items.append(failed_data)
	
	trash_list.remove_at(0)
	trash_list.push_back(failed_data)
	
	var shake_tween = create_tween().set_parallel(true)
	for bin in bin_nodes:
		if bin:
			var pos = bin.position
			shake_tween.tween_property(bin, "position", pos + Vector2(10, 0), 0.05)
			shake_tween.chain().tween_property(bin, "position", pos + Vector2(-10, 0), 0.05)
			shake_tween.chain().tween_property(bin, "position", pos, 0.05)
	
	await get_tree().create_timer(0.2).timeout
	spawn_trash() 

func show_win_popup():
	game_active = false
	win_popup_bg.show()
	clue_label.text = ""
	
	popup_sprite.scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(popup_sprite, "scale", Vector2(0.7, 0.7), 0.5).set_trans(Tween.TRANS_BACK)

func game_over_lose():
	game_active = false
	trash_holder.visible = false
	clue_label.text = ""
	
	lose_popup_bg.show()
	hourglass_anim.play("default") 
	
	lose_popup_holder.scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(lose_popup_holder, "scale", Vector2(0.7, 0.7), 0.5).set_trans(Tween.TRANS_BACK)

# --- Integrated Button Signals ---

func _on_rescue_pressed():
	win_popup_bg.hide()
	# Ensure video is sized correctly again right before playing
	setup_rescue_video()
	rescue_video.show()
	rescue_video.play()

func _on_rescue_video_finished():
	GameManager.load_scene("res://Assets/Scene/science.scn")

func _on_try_pressed():
	GameManager.load_scene(get_tree().current_scene.scene_file_path)

func _on_texture_button_pressed():
	GameManager.load_scene("res://Assets/Scene/science.scn")

func _on_back_pressed():
	GameManager.load_scene("res://Assets/Scene/science.scn")
