extends Control

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	GameManager.complete_minigame("island_1")
	
	# Gray out and disable Next button on start
	$BoardImage/NextButton.disabled = true
	$BoardImage/NextButton.modulate = Color(0.5, 0.5, 0.5)

func _on_back_button_pressed():
	get_tree().paused = false
	GameManager.load_scene("res://Assets/Scene/FableIsland/fableisland.tscn")
	# 👆 Replace with your actual island map path
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
	GameManager.receive_island_reward("island_1.5")

	# Unlock the Next button
	$BoardImage/NextButton.disabled = false
	$BoardImage/NextButton.modulate = Color(1, 1, 1)
