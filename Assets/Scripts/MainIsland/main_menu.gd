extends Control


func _ready() -> void:
	GameManager.reset_game()
	AudioManager.play_music(preload("res://Assets/Audio/Soft_Eng_LoFi.wav"))
	if not GameManager.cutscene_played:
		$Popup/Exit/VBoxContainer2/VBoxContainer/HBoxContainer2/NinePatchRect4/study_btn.disabled = true       # grays it out and blocks clicks
		$Popup/Exit/VBoxContainer2/VBoxContainer/HBoxContainer2/NinePatchRect4/study_btn.modulate.a = 0.4      # optional: make it look faded

func _on_play_btn_pressed() -> void:
	if GameManager.cutscene_played:
		# Skip cutscene — go straight to main island
		get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_island.tscn")
	else:
		# First time — play cutscene
		get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/opening_cutscene.tscn")
		
		


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_quit_btn_pressed() -> void:
	get_tree().quit()
	





func _on_study_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/study_session_main.tscn")
