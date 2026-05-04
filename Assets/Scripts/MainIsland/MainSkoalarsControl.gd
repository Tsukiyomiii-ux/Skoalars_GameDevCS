extends Control

# --- POPUP SCRIPT ---
@export var open_cont: VBoxContainer
@export var volume_cont: VBoxContainer
@export var bottom_cont: VBoxContainer
@onready var reward_cont = $reward_cont
@onready var reward_btn_cont = $reward_btn_cont
@onready var close_cont = $close_cont
@onready var skip_btn = $skip_btn
@onready var anim = $AnimationPlayer

func _ready() -> void:
	AudioManager.play_music(preload("res://Assets/Audio/SoftEng_BG1.wav"))
	process_mode = Node.PROCESS_MODE_ALWAYS

func safe_set_visible(node: Node, visible: bool):
	if node and is_instance_valid(node):
		node.visible = visible

func safe_toggle_visibility(node: Node):
	if node and is_instance_valid(node):
		node.visible = !node.visible

func play():
	get_tree().paused = false

func pause():
	get_tree().paused = true
# --- UI BUTTONS ---
func _on_home_btn_pressed() -> void:
	play()	
	get_tree().change_scene_to_file("res://Assets/Scene/main_menu.tscn")

func _on_mute_btn_pressed():
	AudioManager.toggle_mute()

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _on_skills_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/SkillEquip.tscn")

func show_reward_popup():
	if reward_cont and is_instance_valid(reward_cont):
		reward_cont.visible = true
	else:
		print("reward_cont not found!")

func hide_reward():
	safe_set_visible(reward_cont, false)

func _on_settings_btn_pressed() -> void:
	safe_toggle_visibility(open_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	pause()
	if anim and is_instance_valid(anim):
		anim.play_backwards("blur")

func _on_quit_btn_pressed() -> void:
	play()
	get_tree().change_scene_to_file("res://Assets/Scene/main_menu.tscn")

func _on_play_btn_pressed() -> void:
	play()
	if anim and is_instance_valid(anim):
		anim.play("blur")
	safe_toggle_visibility(open_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)

func _on_volume_btn_pressed() -> void:
	safe_toggle_visibility(volume_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	if anim and is_instance_valid(anim):
		anim.play_backwards("blur")

func _on_ext_btn_pressed() -> void:
	safe_toggle_visibility(volume_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	if anim and is_instance_valid(anim):
		anim.play("blur")

func _on_done_btn_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/main_island.tscn")


func _on_diamond_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/skillShop.tscn")


func _on_map_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scene/mapSelector.tscn")
