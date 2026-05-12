extends Node2D

# 1. Get a reference to the AnimatedSprite2D node
@onready var prof_hoot = $prof_hoot

func _ready() -> void:
	# Ensure the mouse is visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# 2. Start the animation
	# Replace "default" with the actual name of your animation if you renamed it
	if prof_hoot:
		prof_hoot.play("default") 

# --- Button Connections ---

func _on_addition_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/countoria/addition_scene.tscn")

func _on_subtraction_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/countoria/subtraction_scene.tscn")

func _on_multiplication_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/countoria/multiplication_scene.tscn")

func _on_division_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/countoria/division_scene.tscn")


func _on_cancel_pressed() -> void:
	GameManager.load_scene("res://Assets/Scene/StudySession/Zypheria/study_session_main.tscn")
