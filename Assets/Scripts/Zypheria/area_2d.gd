extends Area2D

var level_1_path = "res://Assets/Scene/Zypheria/zypheria_lvl_1.tscn"
var level_2_path = "res://Assets/Scene/Zypheria/zypheria_lvl_2.tscn"

func _on_ready():
	AudioManager.play_music(preload("res://Assets/Audio/GameBG.wav"))


func _on_body_entered(body):
	print("DEBBUG: Something entered the door!")
	print("DEBBUG: It was named: ", body.name)
	
	if body.is_in_group("Skoalars") or body.name == "Skoalars":
		var completed = GameManager.island_progress["island_4"]["minigames_completed"]
		
		if completed >= 2:
			return  # Both done — do nothing
		elif completed >= 1:
			# Level 1 done — go to level 2
			GameManager.load_scene(level_2_path)
		else:
			# First time — go to level 1
			GameManager.load_scene(level_1_path)
