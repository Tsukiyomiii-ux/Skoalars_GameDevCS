extends Control

# --- POPUP SCRIPT ---
@export var open_cont: VBoxContainer
@export var volume_cont: VBoxContainer
@export var bottom_cont: VBoxContainer
@export var close_cont = VBoxContainer
@onready var anim = $MarginContainer/VBoxContainer/Popup/AnimationPlayer

var minimap_fable: Node
var minimap_count: Node
var minimap_blooms: Node
var minimap_zyph: Node	

var lar_min_fable: Node
var lar_min_count: Node
var lar_min_blooms: Node
var lar_min_zyph: Node

var _settings_open: bool = false

var _cooldown_labels = {}

func _ready() -> void:
	AudioManager.play_music(preload("res://Assets/Audio/SoftEng_BG1.wav"))
	process_mode = Node.PROCESS_MODE_ALWAYS
	_set_mouse_filter_recursive(self)
	GameManager.skill_button_state_changed.connect(_on_skill_button_state_changed)
	minimap_fable  = get_tree().get_first_node_in_group("minimap_fable")
	minimap_count  = get_tree().get_first_node_in_group("minimap_count")
	minimap_blooms = get_tree().get_first_node_in_group("minimap_blooms")
	minimap_zyph   = get_tree().get_first_node_in_group("minimap_zyph")
	lar_min_fable  = get_tree().get_first_node_in_group("lar_min_fable")
	lar_min_count  = get_tree().get_first_node_in_group("lar_min_count")
	lar_min_blooms = get_tree().get_first_node_in_group("lar_min_blooms")
	lar_min_zyph   = get_tree().get_first_node_in_group("lar_min_zyph")

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
	call_deferred("_update_minimap_visibility")
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

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if _settings_open:
				_on_play_btn_pressed()
			else:
				_on_settings_btn_pressed()
		elif event.keycode == KEY_M:
			if not _settings_open:
				_toggle_large_minimap()

func _toggle_large_minimap() -> void:
	var island = GameManager.get_current_island()
	var current_scene = get_tree().current_scene.scene_file_path
	var island_overworlds = [
		"res://Assets/Scene/FableIsland/fableisland.tscn",
		"res://Assets/Scene/Countoria/countoria.tscn",
		"res://Assets/Scene/BloomsGrove/science.scn",
		"res://Assets/Scene/Zypheria/zypheria.tscn",
	]

	# Only works on overworld scenes
	if current_scene not in island_overworlds:
		return

	# Determine which large/small pair to toggle
	var small_map: Node
	var large_map: Node
	match island:
		"island_1", "island_1.5":
			small_map = minimap_fable
			large_map = lar_min_fable
		"island_2", "island_2.5":
			small_map = minimap_count
			large_map = lar_min_count
		"island_3", "island_3.5":
			small_map = minimap_blooms
			large_map = lar_min_blooms
		"island_4", "island_4.5":
			small_map = minimap_zyph
			large_map = lar_min_zyph
		_:
			return

	if not small_map or not large_map:
		return

	# Toggle: if large is showing, hide it and show small; vice versa
	var showing_large = large_map.visible
	large_map.visible = not showing_large
	small_map.visible = showing_large

func _update_minimap_visibility() -> void:
	var island = GameManager.get_current_island()
	var current_scene = get_tree().current_scene.scene_file_path
	print("🗺️ current_scene: ", get_tree().current_scene.scene_file_path)
	print("🏝️ island: ", GameManager.get_current_island())
	print("🗺️ minimap_fable: ", minimap_fable)
	print("🗺️ minimap_zyph: ", minimap_zyph)

	# Only show minimap on island overworld scenes
	var island_overworlds = [
		"res://Assets/Scene/FableIsland/fableisland.tscn",
		"res://Assets/Scene/Countoria/countoria.tscn",
		"res://Assets/Scene/BloomsGrove/science.scn",
		"res://Assets/Scene/Zypheria/zypheria.tscn",
	]

	# Hide all first
	if minimap_fable and is_instance_valid(minimap_fable):
		minimap_fable.visible = false
	if minimap_count and is_instance_valid(minimap_count):
		minimap_count.visible = false
	if minimap_blooms and is_instance_valid(minimap_blooms):
		minimap_blooms.visible = false
	if minimap_zyph and is_instance_valid(minimap_zyph):
		minimap_zyph.visible = false

	# If not on an overworld, stop here
	if current_scene not in island_overworlds:
		return

	# Show only the matching island's map
	match island:
		"island_1", "island_1.5":
			if minimap_fable and is_instance_valid(minimap_fable):
				minimap_fable.visible = true
		"island_2", "island_2.5":
			if minimap_count and is_instance_valid(minimap_count):
				minimap_count.visible = true
		"island_3", "island_3.5":
			if minimap_blooms and is_instance_valid(minimap_blooms):
				minimap_blooms.visible = true
		"island_4", "island_4.5":
			if minimap_zyph and is_instance_valid(minimap_zyph):
				minimap_zyph.visible = true

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
	_settings_open = true
	GameManager.settings_opened.emit()
	safe_toggle_visibility(open_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	pause()
	if anim and is_instance_valid(anim):
		anim.play_backwards("blur")
	# Hide minimaps when settings open
	_hide_all_minimaps()

func _on_quit_btn_pressed() -> void:
	GameManager.cleanup_persistent_nodes()
	get_tree().paused = false
	
	# Store current scene BEFORE the await
	var current_scene = get_tree().current_scene.scene_file_path
	
	if anim and is_instance_valid(anim):
		anim.play("blur")
	await anim.animation_finished

	# On main island → go to main menu
	if current_scene == "res://Assets/Scene/MainIsland/main_island.tscn":
		get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_menu.tscn")
		return

	# On an island overworld → go to main island
	var island_overworlds = [
		"res://Assets/Scene/FableIsland/fableisland.tscn",
		"res://Assets/Scene/Countoria/countoria.tscn",
		"res://Assets/Scene/BloomsGrove/science.scn",
		"res://Assets/Scene/Zypheria/zypheria.tscn",
	]
	if current_scene in island_overworlds:
		get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_island.tscn")
		return

	# In a minigame → go back to that island's overworld
	var island = GameManager.get_current_island()
	match island:
		"island_1", "island_1.5", "island_1.1", "island_1.2":  # ✅ add missing ones
			get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/fableisland.tscn")
		"island_2", "island_2.5", "island_2.1", "island_2.2":
			get_tree().change_scene_to_file("res://Assets/Scene/Countoria/countoria.tscn")
		"island_3", "island_3.5", "island_3.1", "island_3.2":
			get_tree().change_scene_to_file("res://Assets/Scene/BloomsGrove/science.scn")
		"island_4", "island_4.5", "island_4.1", "island_4.2":
			get_tree().change_scene_to_file("res://Assets/Scene/Zypheria/zypheria.tscn")
		_:
			get_tree().change_scene_to_file("res://Assets/Scene/MainIsland/main_island.tscn")
func _on_play_btn_pressed() -> void:
	_settings_open = false
	GameManager.settings_closed.emit()
	play()
	if anim and is_instance_valid(anim):
		anim.play("blur")
	safe_toggle_visibility(open_cont)
	safe_toggle_visibility(close_cont)
	safe_toggle_visibility(bottom_cont)
	# Restore minimap when settings close
	_update_minimap_visibility()

func _hide_all_minimaps() -> void:
	if minimap_fable and is_instance_valid(minimap_fable): minimap_fable.visible = false
	if minimap_count and is_instance_valid(minimap_count): minimap_count.visible = false
	if minimap_blooms and is_instance_valid(minimap_blooms): minimap_blooms.visible = false
	if minimap_zyph and is_instance_valid(minimap_zyph): minimap_zyph.visible = false
	if lar_min_fable and is_instance_valid(lar_min_fable): lar_min_fable.visible = false
	if lar_min_count and is_instance_valid(lar_min_count): lar_min_count.visible = false
	if lar_min_blooms and is_instance_valid(lar_min_blooms): lar_min_blooms.visible = false
	if lar_min_zyph and is_instance_valid(lar_min_zyph): lar_min_zyph.visible = false

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
