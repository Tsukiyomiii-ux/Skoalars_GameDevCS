extends CanvasLayer

@onready var owl_sprite = $Bg/Owl

func _ready():
	# Starts the owl animation automatically when the scene opens
	owl_sprite.play("default")
	
	# Connect button signals manually if you haven't via the editor
	$Bg/Anatomy.pressed.connect(_on_anatomy_pressed)
	$Bg/Physiology.pressed.connect(_on_physiology_pressed)
	$Bg/Ecology.pressed.connect(_on_ecology_pressed)
	$Bg/Biodegradable.pressed.connect(_on_biodegradable_pressed)
	$Bg/NonBiodegradable.pressed.connect(_on_non_biodegradable_pressed)
	$Bg/Recyclable.pressed.connect(_on_recyclable_pressed) # Assuming TextureButton is Recyclable
	
	

# --- BUTTON FUNCTIONS ---

func _on_anatomy_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/BloomsGroove/anatomy.tscn")

func _on_physiology_pressed():
	# Path from your request: Physiology-funtion.tscn
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/BloomsGroove/Function.tscn")

func _on_ecology_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/BloomsGroove/ecology.tscn")

func _on_biodegradable_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/BloomsGroove/Biodegradable.tscn")

func _on_non_biodegradable_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/BloomsGroove/NonBiodegradable.tscn")

func _on_recyclable_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/BloomsGroove/Recyclable.tscn")


func _on_cancel_pressed():
	# Return to study menu
	GameManager.load_scene("res://Assets/Scene/StudySession/Zypheria/study_session_main.tscn")
