extends Node2D

# Make sure to change this path to wherever your minigame scene is saved!
var minigame_scene_path = "res://Assets/Scene/BloomsGrove/GardenMiniGame.tscn"

func _on_mini_game_1_entrance_body_entered(body):
	# Assuming your player character is in a group named "player"
	if body.is_in_group("player"):
		print("Player entered the zone! Switching to Minigame via Loading Screen...")
		
		# We use the SceneManager singleton instead of get_tree()
		# This will trigger your loading_screen.tscn automatically
		GameManager.load_scene(minigame_scene_path)
