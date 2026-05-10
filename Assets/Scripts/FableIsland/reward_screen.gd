extends Control

# Node names based on your Scene Tree
@onready var reward_popup = $RewardPopup
@onready var diamond_icon = $TextureRect
@onready var back_btn = $BackButton
@onready var next_btn = $NextButton
@onready var collect_btn = $TextureButton 

func _ready():
	GameManager.complete_minigame("island_1")
	# 1. Hide the +5 text at the start
	if reward_popup:
		reward_popup.modulate.a = 0
		reward_popup.hide()
	
	# 2. Start NEXT disabled so they must collect first
	if next_btn:
		next_btn.disabled = true
		next_btn.modulate.a = 0.5

# --- SIGNALS ---

func _on_texture_button_pressed(): # This is your COLLECT button
	# 1. Disable the button so they can't click it twice
	collect_btn.disabled = true
	GameManager.receive_island_reward("island_1")
	
	# 2. Show and Animate the +5 Popup
	if reward_popup:
		reward_popup.show()
		reward_popup.modulate.a = 1.0 # Make it visible
		
		# Store the original position so we can animate relative to it
		var start_pos_y = reward_popup.position.y
		
		var tween = create_tween().set_parallel(true)
		# Move it up 100 pixels and fade it out
		tween.tween_property(reward_popup, "position:y", start_pos_y - 100, 0.8)
		tween.tween_property(reward_popup, "modulate:a", 0, 0.8)
		
		# Pulse the diamond color (Flash white/bright)
		if diamond_icon:
			var d_tween = create_tween()
			d_tween.tween_property(diamond_icon, "modulate", Color(2, 2, 2), 0.1) 
			d_tween.tween_property(diamond_icon, "modulate", Color(1, 1, 1), 0.1) 
	
	# 3. Enable the NEXT button now that rewards are collected
	if next_btn:
		next_btn.disabled = false
		next_btn.modulate.a = 1.0

func _on_next_button_pressed():
	GameManager.load_scene("res://Assets/Scene/FableIsland/level_2_spelling_quest.tscn")
	
	# 2. Go to the LOADING SCREEN (The loading screen will then take us to Level 2)
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/loading_screen.tscn")

func _on_back_button_pressed():
	GameManager.load_scene("res://Assets/Scene/FableIsland/fableisland.tscn")
	# 👆 Replace with your actual island map scene path
