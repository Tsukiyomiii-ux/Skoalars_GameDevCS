extends Node2D # Note: If this script is on the Entrance, it should say extends Area2D

func _on_entrance_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Skoalars":
		# We use "Assets" because your folder in the screenshot has the 's'
		var level_1_path = "res://Assets/Scene/level_1_countoria.tscn"
		
		# Use call_deferred to be extra safe and avoid that red error
		get_tree().call_deferred("change_scene_to_file", level_1_path)
