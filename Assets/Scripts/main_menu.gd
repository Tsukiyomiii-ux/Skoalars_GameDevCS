extends Control

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/main_island.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_quit_pressed() -> void:
	get_tree().quit()
