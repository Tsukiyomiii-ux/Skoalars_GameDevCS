extends Control

# --- POPUP SCRIPT ---
@export var open_cont: VBoxContainer
@export var volume_cont: VBoxContainer
@export var bottom_cont: VBoxContainer
@export var close_cont = VBoxContainer
@onready var anim = $MarginContainer/VBoxContainer/Popup/AnimationPlayer

var _cooldown_labels = {}

func _ready() -> void:
	AudioManager.play_music(preload("res://Assets/Audio/SoftEng_BG1.wav"))
	process_mode = Node.PROCESS_MODE_ALWAYS
	_set_mouse_filter_recursive(self)
	GameManager.skill_button_state_changed.connect(_on_skill_button_state_changed)
	_cooldown_labels = {
		"hint":        get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect/HCooldownLabel"),
		"freeze_time": get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect2/FCooldownLabel"),
		"add_time":    get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect3/ACooldownLabel"),
		"skip":        get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect4/SCooldownLabel"),
	}
	for skill_name in _cooldown_labels:
		if _cooldown_labels[skill_name] == null:
			print("❌ NULL label: ", skill_name)
			continue
		_cooldown_labels[skill_name].visible = false
		_cooldown_labels[skill_name].text = ""
	set_process(true)

func _process(_delta: float) -> void:
	for skill_name in _cooldown_labels:
		var label = _cooldown_labels[skill_name]
		if label == null:
			continue
		var remaining = GameManager.get_skill_cooldown_remaining(skill_name)
		if remaining > 0.0:
			label.visible = true
			label.text = str(ceili(remaining))
		else:
			label.visible = false
			label.text = ""

func _on_skill_button_state_changed(skill_name, is_disabled):
	var on_cooldown = GameManager.is_skill_on_cooldown(skill_name)
	var should_dim = is_disabled or on_cooldown
	match skill_name:
		"hint":
			var patch = get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect")
			var btn = get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect/hint_btn")
			if patch and btn:
				btn.disabled = should_dim
				patch.modulate = Color(0.3, 0.3, 0.3, 1.0) if should_dim else Color(1, 1, 1, 1)
				if _cooldown_labels.has("hint") and _cooldown_labels["hint"]:
					_cooldown_labels["hint"].modulate = Color(3.33, 3.33, 3.33, 1) if on_cooldown else Color(1, 1, 1, 1)
		"freeze_time":
			var patch = get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect2")
			var btn = get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect2/freeze_btn")
			if patch and btn:
				btn.disabled = should_dim
				patch.modulate = Color(0.3, 0.3, 0.3, 1.0) if should_dim else Color(1, 1, 1, 1)
				if _cooldown_labels.has("freeze_time") and _cooldown_labels["freeze_time"]:
					_cooldown_labels["freeze_time"].modulate = Color(3.33, 3.33, 3.33, 1) if on_cooldown else Color(1, 1, 1, 1)
		"add_time":
			var patch = get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect3")
			var btn = get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect3/addTime_btn")
			if patch and btn:
				btn.disabled = should_dim
				patch.modulate = Color(0.3, 0.3, 0.3, 1.0) if should_dim else Color(1, 1, 1, 1)
				if _cooldown_labels.has("add_time") and _cooldown_labels["add_time"]:
					_cooldown_labels["add_time"].modulate = Color(3.33, 3.33, 3.33, 1) if on_cooldown else Color(1, 1, 1, 1)
		"skip":
			var patch = get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect4")
			var btn = get_node_or_null("MarginContainer/bottom_cont/MarginContainer/VBoxContainer/NinePatchRect4/skip_btn")
			if patch and btn:
				btn.disabled = should_dim
				patch.modulate = Color(0.3, 0.3, 0.3, 1.0) if should_dim else Color(1, 1, 1, 1)
				if _cooldown_labels.has("skip") and _cooldown_labels["skip"]:
					_cooldown_labels["skip"].modulate = Color(3.33, 3.33, 3.33, 1) if on_cooldown else Color(1, 1, 1, 1)

func _set_mouse_filter_recursive(node: Node):
	if node is Control:
		if not node is Button and not node is TextureButton and not node is HSlider:
			node.mouse_filter = Control.MOUSE_FILTER_PASS
	for child in node.get_children():
		_set_mouse_filter_recursive(child)

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
	GameManager.cleanup_persistent_nodes()
	play()
	get_tree().change_scene_to_file("res://Assets/Scene/main_menu.tscn")

func _on_mute_btn_pressed():
	AudioManager.toggle_mute()
	%mute_btn.visible = false
	%unmute_btn.visible = true

func _on_unmute_btn_pressed():
	AudioManager.toggle_mute()
	%mute_btn.visible = true
	%unmute_btn.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _on_skills_btn_pressed() -> void:
	play()
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/SkillEquip.tscn")

func _on_settings_btn_pressed() -> void:
	GameManager.settings_opened.emit()
	safe_toggle_visibility(open_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	pause()
	if anim and is_instance_valid(anim):
		anim.play_backwards("blur")

func _on_quit_btn_pressed() -> void:
	GameManager.cleanup_persistent_nodes()
	get_tree().paused = false
	if anim and is_instance_valid(anim):
		anim.play("blur")
	await anim.animation_finished

	var current_scene = get_tree().current_scene.scene_file_path

	if current_scene == "res://Assets/Scene/MainIsland/main_island.tscn":
		get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_menu.tscn")
		return

	var island = GameManager.get_current_island()
	match island:
		"island_1", "island_1.5":
			get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/fable_island.tscn")
		"island_2", "island_2.5":
			get_tree().change_scene_to_file("res://Assets/Scene/Countoria/countoria.tscn")
		"island_3", "island_3.5":
			get_tree().change_scene_to_file("res://Assets/Scene/BloomsGrove/science.scn")
		"island_4", "island_4.5":
			get_tree().change_scene_to_file("res://Assets/Scene/Zypheria/zypheria.tscn")
		_:
			get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_island.tscn")

func _on_play_btn_pressed() -> void:
	GameManager.settings_closed.emit()
	play()
	if anim and is_instance_valid(anim):
		anim.play("blur")
	safe_toggle_visibility(open_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)

func _on_volume_btn_pressed() -> void:
	GameManager.settings_opened.emit()
	safe_toggle_visibility(volume_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	if anim and is_instance_valid(anim):
		anim.play_backwards("blur")

func _on_ext_btn_pressed() -> void:
	GameManager.settings_closed.emit()
	safe_toggle_visibility(volume_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	if anim and is_instance_valid(anim):
		anim.play("blur")

func _on_done_btn_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/main_island.tscn")

func _on_diamond_btn_pressed() -> void:
	play()
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/skillShop.tscn")

func _on_map_start_btn_pressed() -> void:
	play()
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/mapSelector.tscn")

func _on_hint_btn_pressed():
	GameManager.use_skill("hint")

func _on_freeze_btn_pressed():
	GameManager.use_skill("freeze_time")

func _on_add_time_btn_pressed():
	GameManager.use_skill("add_time")

func _on_skip_btn_pressed():
	GameManager.use_skill("skip")

func _on_study_btn_pressed() -> void:
	var current = get_tree().current_scene.scene_file_path
	if "study_session" in current:
		play()
		if anim and is_instance_valid(anim):
			anim.play("blur")
		safe_set_visible(open_cont, false)
		safe_set_visible(close_cont, true)
		safe_set_visible(bottom_cont, true)
		return
	play()
	if anim and is_instance_valid(anim):
		anim.play("blur")
	await anim.animation_finished
	get_tree().change_scene_to_file("res://Assets/Scene/StudySession/Zypheria/study_session_main.tscn")

func _on_progress_btn_pressed() -> void:
	play()
	get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/Progress.tscn")
