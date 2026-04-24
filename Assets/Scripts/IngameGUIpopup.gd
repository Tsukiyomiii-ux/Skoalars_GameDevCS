extends MarginContainer

@export var close_cont: VBoxContainer
@export var open_cont: VBoxContainer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func pause():
	get_tree().paused = true

func play():
	get_tree().paused = false

func toggle_visibility(object):
	if object.visible:
		object.visible = false
	else:
		object.visible = true

func _on_settings_btn_pressed() -> void:
	toggle_visibility(open_cont)
	toggle_visibility(close_cont)
	pause()


func _on_quit_btn_pressed() -> void:
	get_tree().quit()
	


func _on_play_btn_pressed() -> void:
	play()
	toggle_visibility(open_cont)
	toggle_visibility(close_cont)
	
	
