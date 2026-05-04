extends Control

func _ready():
	# Allow this to run even if the game is paused
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Automatically snap to the middle of the screen
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# Fix for "Frozen Buttons": Make sure backgrounds don't block clicks
	if has_node("BlurBackground"):
		$BlurBackground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if has_node("BoardImage"):
		$BoardImage.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Connected to RetryButton
func _on_back_button_pressed():
	print("Going back to Level 2...")
	get_tree().paused = false # Essential so the Timer can run!
	
	# 1. Set the destination
	Global.target_level = "res://Assets/Scene/FableIsland/level_2_spelling_quest.tscn"
	
	# 2. Go to the loading screen
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/loading_screen.tscn")

func _on_next_button_pressed():
	# If you want to prepare for a Level 3 later:
	print("Next level coming soon!")
	# For now, maybe just send them back to the Island?
	# Global.target_level = "res://Assets/Scene/fableisland.tscn"
	# get_tree().change_scene_to_file("res://Assets/Scene/loading_screen.tscn")

func _on_rewards_button_pressed():
	print("Diamond Collected!")
	var btn = $BoardImage/RewardsButton
	btn.disabled = true 
	btn.modulate = Color(0.5, 0.5, 0.5)
	# You could even add code here to save the diamond to Global.score!


func _on_quit_button_pressed() -> void:
	print("Quitting to Map...")
	# 1. Unpause the game so the next scene can run
	get_tree().paused = false
	
	# 2. Tell the Global script the destination is the Island
	Global.target_level = "res://Assets/Scene/FableIsland/fableisland.tscn"
	
	# 3. Go to the loading screen
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/loading_screen.tscn")


func _on_retry_button_pressed() -> void:
	print("Retrying Level...")
	# 1. Unpause the game
	get_tree().paused = false
	
	# 2. Tell the Global script to restart this specific level
	Global.target_level = "res://Assets/Scene/FableIsland/level_2_spelling_quest.tscn"
	
	# 3. Go to the loading screen
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/loading_screen.tscn")
