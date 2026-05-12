extends Area2D

func _on_body_entered(body):
	print("DEBBUG: Something entered the door!")
	print("DEBBUG: It was named: ", body.name)
	
	if body.name == "Skoalars" or body.is_in_group("player"):
		get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/study_session_main.tscn")
