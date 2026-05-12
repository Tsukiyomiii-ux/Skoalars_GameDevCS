extends Control

@onready var literacy_bar = $NinePatchRect/MarginContainer/HBoxContainer/VBoxContainer/NinePatchRect/LiteracyPB
@onready var math_bar = $NinePatchRect/MarginContainer/HBoxContainer/VBoxContainer/NinePatchRect2/MathPB
@onready var science_bar = $NinePatchRect/MarginContainer/HBoxContainer/VBoxContainer/NinePatchRect3/SciencePB
@onready var geography_bar = $NinePatchRect/MarginContainer/HBoxContainer/VBoxContainer/NinePatchRect4/GeographyPB
@onready var cancel_btn = $NinePatchRect/cancel_btn

func _ready():  # ✅ Fixed from _on_ready()

	
	literacy_bar.max_value = 100
	math_bar.max_value = 100
	science_bar.max_value = 100
	geography_bar.max_value = 100
	
	literacy_bar.value = GameManager.get_study_progress("literacy") * 100
	math_bar.value = GameManager.get_study_progress("math") * 100
	science_bar.value = GameManager.get_study_progress("science") * 100
	geography_bar.value = GameManager.get_study_progress("geography") * 100

func _on_cancel_btn_pressed():
	var island_scenes = {
		"island_1": "res://Assets/Scene/FableIsland/fableisland.tscn",
		"island_1.1": "res://Assets/Scene/FableIsland/level_1_maze.tscn",
		"island_1.2": "res://Assets/Scene/FableIsland/level_2_spelling_quest.tscn",
		"island_2": "res://Assets/Scene/Countoria/countoria.tscn",
		"island_2.1": "res://Assets/Scene/Countoria/level_1_countoria.tscn",
		"island_2.2": "res://Assets/Scene/Countoria/level_2_countoria.tscn",
		"island_3": "res://Assets/Scene/BloomsGrove/science.scn",
		"island_3.1": "res://Assets/Scene/BloomsGrove/GardenMiniGame.tscn",
		"island_3.2": "res://Assets/Scene/BloomsGrove/Minigame2.tscn",
		"island_4": "res://Assets/Scene/Zypheria/zypheria.tscn",
		"island_4.1": "res://Assets/Scene/Zypheria/zypheria_lvl_1.tscn",
		"island_4.2": "res://Assets/Scene/Zypheria/zypheria_lvl_2.tscn",
		"island_5": "res://Assets/Scene/MainIsland/main_island.tscn",
		"study": "res://Assets/Scene/StudySession/Zypheria/study_session_main.tscn"
	}
	var scene = island_scenes.get(GameManager.get_current_island(), "res://Assets/Scene/MainIsland/main_island.tscn")
	get_tree().change_scene_to_file(scene)  # ✅ Already correct here
