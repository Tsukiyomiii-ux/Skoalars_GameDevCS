extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.set_current_island("island_1")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_libaray_door_body_entered(body: Node2D) -> void:
	if body.name == "Skoalars":
		# 1. Set the destination in the Global script first
		Global.target_level = "res://Assets/Scene/FableIsland/level_1_maze.tscn"
		
		# 2. THEN change scene to the loading screen
		get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/loading_screen.tscn")
