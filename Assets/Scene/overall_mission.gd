extends Control

func _on_ready():
	AudioManager.play_music(preload("res://Assets/Audio/SoftEng_FableIsle.wav"))

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/Tutorial.tscn")
