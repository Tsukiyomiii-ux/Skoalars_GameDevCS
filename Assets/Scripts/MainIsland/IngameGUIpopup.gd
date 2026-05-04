extends MarginContainer

@export var close_cont: VBoxContainer
@export var open_cont: VBoxContainer
@export var volume_cont: VBoxContainer
@export var bottom_cont: VBoxContainer
@export var skip_btn: Button
@export var done_btn: Button
@export var reward_btn_cont: HBoxContainer
@export var quest_Cont: NinePatchRect
@onready var reward_cont = $reward_cont

var step := 0
var tutorial_done := false
var reward_shown := false


func _ready():
	GameManager.set_ui(
		$RewardCont,
		$RewardBtnCont,
		$CloseCont,
		$DoneBtn,
		$SkipBtn,
		$AnimationPlayer
	)

func show_reward_popup():
	if reward_cont == null:
		print("reward_cont not found!")
		return

	reward_cont.visible = true

func pause():
	get_tree().paused = true

func play():
	get_tree().paused = false


func toggle_visibility(object):
	if object:
		object.visible = !object.visible


func hide_reward():
	if reward_cont:
		reward_cont.visible = false

func _on_settings_btn_pressed() -> void:
	toggle_visibility(open_cont)
	toggle_visibility(close_cont)
	toggle_visibility(bottom_cont)
	pause()
	$AnimationPlayer.play_backwards("blur")

func _on_quit_btn_pressed() -> void:
	play()
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_menu.tscn")

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

func _unhandled_input(event):
	if tutorial_done:
		return

	if event.is_action_pressed("ui_down"):
		step += 1

func _on_skip_btn_pressed() -> void:
	toggle_visibility(quest_Cont)
	#if not reward_shown:
		#show_reward()
	return

func _on_done_btn_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_island.tscn")

func show_reward():
	reward_shown = true
	
	tutorial_done = true

	toggle_visibility(reward_cont)
	toggle_visibility(reward_btn_cont)
	toggle_visibility(close_cont)
	toggle_visibility(done_btn)
	toggle_visibility(skip_btn)

	$AnimationPlayer.play_backwards("blur")
