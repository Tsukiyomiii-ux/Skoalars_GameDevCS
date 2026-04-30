extends VideoStreamPlayer

var is_paused := false
func _ready ():
	AudioManager.stop_music()
	play()

# Skip button
func _on_skip_btn_pressed():
	stop()
	get_tree().change_scene_to_file("res://Assets/Scene/Tutorial.tscn")

# Pause / Play toggle
func _on_pasplay_btn_pressed():
	if is_paused:
		play()
		paused = !paused
		
	else:
		paused = true
		is_paused = true

# When video finishes normally
func _on_finished():
	get_tree().change_scene_to_file("res://Assets/Scene/main_island.tscn")
