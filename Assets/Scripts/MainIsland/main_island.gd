extends Node2D


func _ready():
	GameManager.set_current_island("island_5")  # change per island
	AudioManager.play_music(preload("res://Assets/Audio/GameBG.wav"))
