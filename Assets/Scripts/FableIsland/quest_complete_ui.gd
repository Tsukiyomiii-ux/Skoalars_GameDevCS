extends Control

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Gray out and disable Next button on start
	$BoardImage/NextButton.disabled = true
	$BoardImage/NextButton.modulate = Color(0.5, 0.5, 0.5)

func _on_back_button_pressed():
	print("Going back to Level 2...")
	get_tree().paused = false # Essential so the loading bar can animate!
	
	# 1. Set the destination to restart Level 2
	Global.target_level = "res://Assets/Scene/FableIsland/level_2_spelling_quest.tscn"
	
	# 2. Go to the loading screen
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/loading_screen.tscn")

func _on_next_button_pressed():
	print("Next button pressed! Starting Lore Animation...")
	# 1. Unpause so the video scene can process!
	get_tree().paused = false 
	
	# 2. Go DIRECTLY to the Movie Scene
	# (Note: Use the exact path to your movie scene file)
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/lore_movie_scene.tscn")

func _on_rewards_button_pressed():
	print("Diamond Collected!")
	var btn = $BoardImage/RewardsButton
	btn.disabled = true
	btn.modulate = Color(0.5, 0.5, 0.5)

	# Unlock the Next button
	$BoardImage/NextButton.disabled = false
	$BoardImage/NextButton.modulate = Color(1, 1, 1)
