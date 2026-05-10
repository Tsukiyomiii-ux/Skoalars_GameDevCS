extends Control

func _on_play_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/opening_cutscene.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_quit_btn_pressed() -> void:
	get_tree().quit()
	

func _ready() -> void:
	AudioManager.play_music(preload("res://Assets/Audio/Soft_Eng_LoFi.wav"))
	GameManager.reset_game()
