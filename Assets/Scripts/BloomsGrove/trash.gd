extends Area2D

var is_dragging = false
var type = "" 

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed
		get_viewport().set_input_as_handled()

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_dragging:
			is_dragging = false
			check_drop()

func check_drop():
	var areas = get_overlapping_areas()
	var hit_any_bin = false
	
	for area in areas:
		# Check for correct bin
		if area.is_in_group(type):
			correct_placement()
			return
		
		# Check for wrong bin
		if area.is_in_group("bio") or area.is_in_group("recycle") or area.is_in_group("nonbio") or area.name.begin_with("Bin_"):
			hit_any_bin = true
	
	if hit_any_bin:
		wrong_placement()
	else:
		# Slide back if dropped in empty space
		var tween = create_tween()
		tween.tween_property(self, "position", get_parent().size / 2, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func correct_placement():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 0.1)
	
	if get_tree().current_scene.has_method("update_score"):
		get_tree().current_scene.update_score()
	
	await tween.finished
	queue_free()

func wrong_placement():
	if get_tree().current_scene.has_method("handle_wrong_answer"):
		get_tree().current_scene.handle_wrong_answer()
	
	queue_free()
