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
	get_tree().change_scene_to_file("res://Assets/Scene/addition_scene.tscn")

func _on_subtraction_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/subtraction_scene.tscn")

func _on_multiplication_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/multiplication_scene.tscn")

func _on_division_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/division_scene.tscn")
