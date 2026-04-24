extends Control
func play():
	get_tree().paused = false

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/fableisland.tscn")


func _on_home_btn_pressed() -> void:
	play()	
	get_tree().change_scene_to_file("res://Assets/Scene/main_menu.tscn")
	
