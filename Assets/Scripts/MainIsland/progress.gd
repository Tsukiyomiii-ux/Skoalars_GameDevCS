extends Control

func _on_cancel_btn_pressed():
	var island_scenes = {
		"island_1": "res://Assets/Scene/FableIsland/fableisland.tscn",
		"island_2": "res://Assets/Scene/Countoria/countoria.tscn",
		"island_3": "res://Assets/Scene/BloomsGrove/science.scn",
		"island_4": "res://Assets/Scene/Zypheria/zypheria.tscn",
		"island_5": "res://Assets/Scene/MainIsland/main_island.tscn",
	}
	var scene = island_scenes.get(GameManager.get_current_island(), "res://Assets/Scene/MainIsland/main_island.tscn")
	get_tree().change_scene_to_file(scene)
