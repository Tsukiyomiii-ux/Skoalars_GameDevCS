extends Area2D

var level_1_path = "res://Assets/Scene/Zypheria/zypheria_lvl_1.tscn"

func _on_body_entered(body):
	# Debugging prints
	print("DEBBUG: Something entered the door!")
	print("DEBBUG: It was named: ", body.name)
	
	# Check if the player entered
	if body.is_in_group("Skoalars") or body.name == "Skoalars":
		# 1. Store the next destination in the global GameManager
		GameManager.next_scene_path = level_1_path
		
		# 2. Change scene to the loading screen
		get_tree().change_scene_to_file("res://Assets/Scene/Zypheria/loading_screen.tscn")
