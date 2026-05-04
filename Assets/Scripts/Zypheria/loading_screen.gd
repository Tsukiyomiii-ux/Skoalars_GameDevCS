extends Node2D

# Updated paths to match your new hierarchy:
# loading_screen -> CanvasLayer -> Sprite2D -> ProgressBar -> Label
@onready var progress_bar = $CanvasLayer/Sprite2D/ProgressBar
@onready var loading_label = $CanvasLayer/Sprite2D/ProgressBar/Label

var target_scene_path: String
var progress = []

func _ready():
	target_scene_path = GameManager.next_scene_path
	
	if target_scene_path == "":
		if loading_label:
			loading_label.text = "Error: No scene path set"
		return
		
	ResourceLoader.load_threaded_request(target_scene_path)

func _process(_delta):
	var status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	if progress.size() > 0:
		var current_progress = progress[0] * 100
		if progress_bar:
			progress_bar.value = current_progress
		if loading_label:
			loading_label.text = "Loading... " + str(int(current_progress)) + "%"
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().create_timer(0.5).timeout
		var new_scene = ResourceLoader.load_threaded_get(target_scene_path)
		get_tree().change_scene_to_packed(new_scene)
	
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		if loading_label:
			loading_label.text = "Loading Failed!"
