extends Node2D

# References to the buttons inside the container hierarchy
@onready var literacy_btn = $CanvasLayer3/HBoxContainer/GridContainer/LiteracyBtn
@onready var math_btn = $CanvasLayer3/HBoxContainer/GridContainer/MathBtn
@onready var science_btn = $CanvasLayer3/HBoxContainer/GridContainer/ScienceBtn
@onready var geography_btn = $CanvasLayer3/HBoxContainer/GridContainer/GeographyBtn
var settings_open: bool = false
func _ready():
	AudioManager.play_music(preload("res://Assets/Audio/StudySessionBG.wav"))
	# Store all buttons in a list for easier signal connecting
	var buttons = [literacy_btn, math_btn, science_btn, geography_btn]
	GameManager.set_current_island("study")
	for btn in buttons:
		# Connect the click signal
		
		# Connect hover signals
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))
		
		# Crucial: Set the pivot to the center so the hover scale expands outward
		btn.pivot_offset = btn.size / 2
		
	$CanvasLayer3/HBoxContainer/GridContainer/LiteracyBtn.pressed.connect(_on_literacy_pressed)
	$CanvasLayer3/HBoxContainer/GridContainer/MathBtn.pressed.connect(_on_mathematics_pressed)
	$CanvasLayer3/HBoxContainer/GridContainer/ScienceBtn.pressed.connect(_on_science_pressed)
	$CanvasLayer3/HBoxContainer/GridContainer/GeographyBtn.pressed.connect(_on_geography_pressed)
	
	GameManager.settings_opened.connect(_on_settings_opened)
	GameManager.settings_closed.connect(_on_settings_closed)

var grid_was_visible: bool = true  # Add at top of script

func _on_settings_opened():
	settings_open = true
	get_tree().paused = false
	var grid = $CanvasLayer3/HBoxContainer/GridContainer
	if grid:
		grid_was_visible = grid.visible  # ✅ Remember if grid was visible
		for btn in [literacy_btn, math_btn, science_btn, geography_btn]:
			btn.disabled = true
		grid.hide()

func _on_settings_closed():
	print("❌ settings_closed called! grid_was_visible: ", grid_was_visible)
	settings_open = false
	var grid = $CanvasLayer3/HBoxContainer/GridContainer
	if grid and grid_was_visible:
		for btn in [literacy_btn, math_btn, science_btn, geography_btn]:
			btn.disabled = false
		grid.show()
		
func _disconnect_settings_signals():
	if GameManager.settings_opened.is_connected(_on_settings_opened):
		GameManager.settings_opened.disconnect(_on_settings_opened)
	if GameManager.settings_closed.is_connected(_on_settings_closed):
		GameManager.settings_closed.disconnect(_on_settings_closed)
func _on_literacy_pressed():
	_disconnect_settings_signals()
	$CanvasLayer3/HBoxContainer/GridContainer.hide()
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/FableIsland/literacy_intro.tscn")

func _on_mathematics_pressed():
	_disconnect_settings_signals()
	$CanvasLayer3/HBoxContainer/GridContainer.hide()
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/countoria/studysession_countoria.tscn")

func _on_science_pressed():
	_disconnect_settings_signals()
	$CanvasLayer3/HBoxContainer/GridContainer.hide()
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/BloomsGroove/science_study.tscn")

func _on_geography_pressed():
	_disconnect_settings_signals()
	$CanvasLayer3/HBoxContainer/GridContainer.hide()
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/geography_study_lesson.tscn")


func _on_button_hover(btn: TextureButton):
	var tween = create_tween()
	tween.set_parallel(true) # Run scale and color change at the same time
	tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_QUAD)
	btn.modulate = Color(1.2, 1.2, 1.2) 

# Function to reset the button when the mouse leaves
func _on_button_unhover(btn: TextureButton):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD)
	btn.modulate = Color(1, 1, 1)
