extends MarginContainer

@export var close_cont: VBoxContainer
@export var open_cont: VBoxContainer
@export var volume_cont: VBoxContainer
@export var bottom_cont: VBoxContainer

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
	toggle_visibility(bottom_cont)
	pause()
	$AnimationPlayer.play_backwards("blur")


func _on_quit_btn_pressed() -> void:
	play()	
	get_tree().change_scene_to_file("res://Assets/Scene/main_menu.tscn")
	
	
	


func _on_play_btn_pressed() -> void:
	play()
	$AnimationPlayer.play("blur")
	toggle_visibility(open_cont)
	toggle_visibility(close_cont)
	toggle_visibility(bottom_cont)


func _on_volume_btn_pressed() -> void:
	toggle_visibility(volume_cont)
	toggle_visibility(close_cont)
	toggle_visibility(bottom_cont)
	$AnimationPlayer.play_backwards("blur")


func _on_ext_btn_pressed() -> void:
	toggle_visibility(volume_cont)
	toggle_visibility(close_cont)
	toggle_visibility(bottom_cont)
	$AnimationPlayer.play("blur")
