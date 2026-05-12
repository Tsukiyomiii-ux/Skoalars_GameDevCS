extends Area2D

func _ready() -> void:
	AudioManager.play_music(preload("res://Assets/Audio/GameBG.wav"))
	GameManager.set_current_island("island_2")
	monitoring = true
	monitorable = true

func _process(_delta):
	var bodies = get_overlapping_bodies()
	var areas = get_overlapping_areas()
	
	for body in bodies:
		if body.name == "Skoalars" or body.is_in_group("player"):
			_enter_island()
			return
	
	for area in areas:
		if area.name == "Skoalars" or area.is_in_group("player"):
			_enter_island()
			return

func _enter_island():
	var completed = GameManager.island_progress["island_2"]["minigames_completed"]
	
	if completed >= 2:
		return  # Both done — do nothing
	elif completed >= 1:
		get_tree().call_deferred("change_scene_to_file", "res://Assets/Scene/Countoria/level_2_countoria.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://Assets/Scene/Countoria/level_1_countoria.tscn")
