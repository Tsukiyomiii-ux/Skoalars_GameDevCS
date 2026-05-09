extends CanvasLayer

func show_screen():
	self.visible = true
	get_tree().paused = true # Freeze the maze

func _on_retry_button_pressed():
	# 1. Unpause so the loading bar can move
	get_tree().paused = false
	
	# 2. Tell Global we want to restart the Maze
	Global.target_level = "res://Assets/Scene/FableIsland/level_1_maze.tscn"
	
	# 3. Go to the LOADING SCREEN
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/loading_screen.tscn")
	
func _on_quit_button_pressed():
	# 1. Clean up variables
	Global.skip_mission = false
	get_tree().paused = false # Always unpause when leaving a menu!
	
	Global.target_level = "res://Assets/Scene/FableIsland/fableisland.tscn"
	
	# 3. Go to the LOADING SCREEN
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/loading_screen.tscn")
