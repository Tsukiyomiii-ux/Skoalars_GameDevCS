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

@onready var wand_button = $Holderwand/Wand

@onready var win_popup_bg = $ColorRect
@onready var popup_sprite = $ColorRect/Popup
@onready var lose_popup_bg = $ColorRect2 
@onready var lose_popup_holder = $ColorRect2/Over
@onready var hourglass_anim = $ColorRect2/Over/Hourglass 
@onready var rescue_video = $RescueVideo 

@onready var sfx_correct = $SfxCorrect
@onready var sfx_wrong = $SfxWrong
@onready var bin_nodes = [$Bin_bio, $Bin_non, $Bin_rec]

const ORIGINAL_MISSION = "Become a Recycling Hero! Drag the trash into the right bins to clean up the park.\n\nBe quick—you have 1 minute to sort everything!"

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
	
	if GameManager and GameManager.wand_used:
		wand_button.disabled = true
		wand_button.modulate = Color(0.5, 0.5, 0.5, 1)
	
	setup_rescue_video()
	rescue_video.hide()
	
	if not rescue_video.finished.is_connected(_on_rescue_video_finished):
		rescue_video.finished.connect(_on_rescue_video_finished)
	
	start_countdown()

func setup_rescue_video():
	# This ensures the video renders ON TOP of everything else in the scene
	rescue_video.z_index = 100 
	rescue_video.top_level = true 
	rescue_video.expand = true 
	rescue_video.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func start_countdown():
	var countdown = 5 
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
		var mins = int(floor(time_left / 60))
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
		
	var trash_scene = preload("res://Assets/Scene/BloomsGrove/Trash.tscn")
	var new_trash = trash_scene.instantiate()
	var data = trash_list[0]
	
	trash_holder.add_child(new_trash)
	new_trash.position = Vector2(trash_holder.size.x / 2, trash_holder.size.y / 2)
	new_trash.get_node("Sprite2D").texture = data["texture"]
	new_trash.type = data["type"]
	
	if data in failed_items:
		match data["type"]:
			"bio": clue_label.text = "Hint: I was once part of something living. I can rot!"
			"recycle": clue_label.text = "Hint: I can become a brand new bottle or can!"
			"nonbio": clue_label.text = "Hint: I don't rot and I can't be remade."
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
	tween.tween_property(lose_popup_holder, "scale", Vector2(0.8, 0.8), 0.5).set_trans(Tween.TRANS_BACK)

func _on_wand_pressed():
	if GameManager.wand_used or not game_active: return
	
	var current_trash = null
	for child in trash_holder.get_children():
		if child is Area2D:
			current_trash = child
			break
			
	if current_trash:
		GameManager.wand_used = true
		wand_button.disabled = true 
		wand_button.modulate = Color(0.5, 0.5, 0.5, 1)
		
		var target_bin = null
		match current_trash.type:
			"bio": target_bin = $Bin_bio
			"nonbio": target_bin = $Bin_non
			"recycle": target_bin = $Bin_rec
			
		if target_bin:
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(current_trash, "global_position", target_bin.global_position, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(current_trash, "scale", Vector2(0.2, 0.2), 0.5)
			tween.tween_property(current_trash, "modulate:a", 0.0, 0.5)
			await tween.finished
			update_score()

func _on_rescue_pressed():
	# Hide all UI popups so they don't block the video
	win_popup_bg.hide()
	lose_popup_bg.hide()
	
	# Make sure video is visible and playing
	rescue_video.show()
	rescue_video.play()

func _on_rescue_video_finished():
	GameManager.load_scene("res://Assets/Scene/MainIsland/mapSelector.tscn")
	GameManager.unlock_island("island_4")

func _on_try_pressed():
	GameManager.load_scene(get_tree().current_scene.scene_file_path)

func _on_back_pressed():
	GameManager.load_scene("res://Assets/Scene/BloomsGrove/science.scn")

func _on_quit_pressed() -> void:
	GameManager.load_scene("res://Assets/Scene/BloomsGrove/science.scn")
