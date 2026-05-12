extends Node2D

var minigame_scene_path = "res://Assets/Scene/BloomsGrove/GardenMiniGame.tscn"

func _ready() -> void:
	AudioManager.play_music(preload("res://Assets/Audio/GameBG.wav"))
	GameManager.set_current_island("island_3")

func _on_mini_game_1_entrance_body_entered(body):
	if body.is_in_group("player"):
		var completed = GameManager.island_progress["island_3"]["minigames_completed"]
		
		if completed >= 2:
			return  # Both done — do nothing
		elif completed >= 1:
			# Level 1 done — go to level 2
			GameManager.load_scene("res://Assets/Scene/BloomsGrove/Minigame2.tscn")
		else:
			# First time — go to level 1
			GameManager.load_scene(minigame_scene_path)
