extends VideoStreamPlayer

@export var pasplay_btn: Button
@export var paspause_btn: Button

var is_paused := false

func _ready():
	AudioManager.stop_music()
	play()
	# Play button hidden at start, pause button visible
	pasplay_btn.visible = false
	paspause_btn.visible = true

# Skip button
func _on_skip_btn_pressed():
	stop()
	get_tree().change_scene_to_file("res://Assets/Scene/Tutorial.tscn")

# Pause button pressed — pause the video, show play button
func _on_paspause_btn_pressed():
	paused = true
	is_paused = true
	pasplay_btn.visible = true
	paspause_btn.visible = false

# Play button pressed — resume the video, show pause button
func _on_pasplay_btn_pressed():
	paused = false
	is_paused = false
	pasplay_btn.visible = false
	paspause_btn.visible = true

# When video finishes normally
func _on_finished():
	get_tree().change_scene_to_file("res://Assets/Scene/main_island.tscn")
