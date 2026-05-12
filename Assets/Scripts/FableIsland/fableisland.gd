extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.set_current_island("island_1")
	AudioManager.play_music(preload("res://Assets/Audio/GameBG.wav"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_libaray_door_body_entered(body: Node2D) -> void:
	if body.name == "Skoalars":
		var completed = GameManager.island_progress["island_1"]["minigames_completed"]
		
		if completed >= 2:
			# Both minigames done — do nothing
			return
		elif completed >= 1:
			# Minigame 1 done — go to level 2
			GameManager.load_scene("res://Assets/Scene/FableIsland/level_2_spelling_quest.tscn")
		else:
			# First time — start from level 1
			GameManager.load_scene("res://Assets/Scene/FableIsland/level_1_maze.tscn")
