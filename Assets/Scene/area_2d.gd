extends Area2D

var level_1_path = "res://Assets/Scene/zypheria_lvl_1.tscn"

func _on_body_entered(body):
	# This will print to the gray box at the bottom of Godot no matter what
	print("DEBBUG: Something entered the door!")
	print("DEBBUG: It was named: ", body.name)
	
	if body.is_in_group("Skoalars") or body.name == "Skoalars":
		# 1. Store the destination in your Global GameManager
		GameManager.next_scene_path = level_1_path
		
		# 2. Change the scene to your parchment loading screen instead of Level 1 directly
		get_tree().change_scene_to_file("res://Assets/Scene/loading_screen.tscn")
