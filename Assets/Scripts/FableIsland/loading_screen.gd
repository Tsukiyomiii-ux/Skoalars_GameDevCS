extends Control

# Use the exact names of your nodes here!
@onready var filling = $BarFrame/BlueFilling 

func _ready():
	# 1. Start the blue part at 0
	filling.value = 0
	
	# 2. Make it grow smoothly over 3 seconds
	var tween = create_tween()
	tween.tween_property(filling, "value", 100, 3.0)
	
	# 3. Wait for the timer to finish
	$Timer.timeout.connect(_on_timer_finished)

func _on_timer_finished():
	# Go to the level stored in your Global script
	if Global.target_level != "":
		get_tree().change_scene_to_file(Global.target_level)
	else:
		print("Error: Global.target_level is empty!")
