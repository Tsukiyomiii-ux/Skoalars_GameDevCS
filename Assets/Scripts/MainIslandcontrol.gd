extends Control
func play():
	get_tree().paused = false

func _on_home_btn_pressed() -> void:
	play()	
	get_tree().change_scene_to_file("res://Assets/Scene/main_menu.tscn")
	

func _on_mute_btn_pressed():
	AudioManager.toggle_mute()

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _ready() -> void:
	AudioManager.play_music(preload("res://Assets/Audio/SoftEng_BG1.wav"))
	


func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/fableisland.tscn")
