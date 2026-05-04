extends Area2D

func _on_body_entered(body):
	# Check if the thing touching the book is our hero
	if body.name == "Skoalars":
		print("Book touched! Teleporting to Reward Screen...")
		
		# Change the scene to your Reward Screen
		# Make sure this path matches your folder exactly!
		get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/reward_screen.tscn")
