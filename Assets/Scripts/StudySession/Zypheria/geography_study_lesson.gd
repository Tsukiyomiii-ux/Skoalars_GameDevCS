extends Node2D

# References to the Geography lesson buttons
@onready var flags_btn = $CanvasLayer/HBoxContainer/GridContainer/FlagsBtn
@onready var capitals_btn = $CanvasLayer/HBoxContainer/GridContainer/CapitalsBtn
@onready var continents_btn = $CanvasLayer/HBoxContainer/GridContainer/ContinentsBtn
@onready var tectonic_btn = $CanvasLayer/HBoxContainer/GridContainer/TectonicBtn

# Reference for the Cancel Button
@onready var cancel_button = $CanvasLayer/CancelButton

func _ready():
	AudioManager.play_music(preload("res://Assets/Audio/StudySessionBG.wav"))
	# Group lesson buttons for easy setup
	var lesson_buttons = [flags_btn, capitals_btn, continents_btn, tectonic_btn]
	
	# Setup Lesson Buttons
	for btn in lesson_buttons:
		btn.pressed.connect(_on_lesson_selected.bind(btn.name))
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))
		btn.pivot_offset = btn.size / 2
	
	# Setup Cancel Button
	cancel_button.pressed.connect(_on_cancel_pressed)
	cancel_button.mouse_entered.connect(_on_button_hover.bind(cancel_button))
	cancel_button.mouse_exited.connect(_on_button_unhover.bind(cancel_button))
	cancel_button.pivot_offset = cancel_button.size / 2

# Logic to return to the main study hub
func _on_cancel_pressed():

	GameManager.load_scene("res://Assets/Scene/StudySession/Zypheria/study_session_main.tscn")

# Handles switching to specific geography lessons
func _on_lesson_selected(btn_name: String):
	var scene_path = ""
	
	match btn_name:
		"FlagsBtn":
			scene_path = "res://Assets/Scene/StudySession/Zypheria/flags_lesson.tscn"
		"CapitalsBtn":
			scene_path = "res://Assets/Scene/StudySession/Zypheria/capitals_lesson.tscn"
		"ContinentsBtn":
			scene_path = "res://Assets/Scene/StudySession/Zypheria/continents_shape_lesson.tscn"
		"TectonicBtn":
			scene_path = "res://Assets/Scene/StudySession/Zypheria/tectonic_lesson.tscn"
	
	if scene_path != "":
		print("Opening: ", scene_path)
		get_tree().change_scene_to_file(scene_path)

# Shared hover animations for all buttons
func _on_button_hover(btn: TextureButton):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(btn, "modulate", Color(1.1, 1.1, 1.1), 0.1)

func _on_button_unhover(btn: TextureButton):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(btn, "modulate", Color(1, 1, 1), 0.1)
