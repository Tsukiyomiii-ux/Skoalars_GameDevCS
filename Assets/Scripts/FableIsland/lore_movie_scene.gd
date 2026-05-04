extends Control

# This script handles playing the lore video and then moving to the loading screen

func _ready():
	# 1. Make sure the game is definitely unpaused so the video and timer run
	get_tree().paused = false
	
	# 2. Connect the timer to the function that switches scenes
	# Make sure your Timer is a child of the VideoStreamPlayer or the root node
	$Timer.timeout.connect(_on_video_finished)
	
	print("Lore movie started...")

func _on_video_finished():
	print("Video done! Switching to loading screen...")
	
	# 3. Tell Global where we want to land after the loading bar fills
	Global.target_level = "res://Assets/Scene/FableIsland/fableisland.tscn"
	
	
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/loading_screen.tscn")
