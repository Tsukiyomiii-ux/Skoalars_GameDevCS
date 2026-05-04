extends Area2D

func _ready() -> void:
	GameManager.set_current_island("island_2")
	monitoring = true
	monitorable = true

func _process(_delta):
	var bodies = get_overlapping_bodies()
	var areas = get_overlapping_areas()
	
	for body in bodies:
		print("Overlapping body: ", body.name)
		if body.name == "Skoalars" or body.is_in_group("player"):
			get_tree().call_deferred("change_scene_to_file", "res://Assets/Scene/Countoria/level_1_countoria.tscn")
	
	for area in areas:
		print("Overlapping area: ", area.name)
		if area.name == "Skoalars" or area.is_in_group("player"):
			get_tree().call_deferred("change_scene_to_file", "res://Assets/Scene/Countoria/level_1_countoria.tscn")
