extends Area2D

func _ready() -> void:
	AudioManager.play_music(preload("res://Assets/Audio/GameBG.wav"))
	GameManager.set_current_island("island_2")
	# ✅ Force HUD to refresh minimap after island is set
	await get_tree().process_frame
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("_update_minimap_visibility"):
		hud._update_minimap_visibility()
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
