extends Node2D
@export var left_arrow: TileMapLayer
@export var up_arrow: TileMapLayer
@export var right_arrow: TileMapLayer
@export var down_arrow: TileMapLayer

signal tutorial_finished  # ✅ signal instead of popup_node

var step := 0
var busy := false
var completed := false

func _ready():
	hide_all()
	show_current_step()

func hide_all():
	left_arrow.visible = false
	up_arrow.visible = false
	right_arrow.visible = false
	down_arrow.visible = false

func show_current_step():
	hide_all()
	match step:
		0: left_arrow.visible = true
		1: up_arrow.visible = true
		2: right_arrow.visible = true
		3: down_arrow.visible = true

func _unhandled_input(event):
	if completed or busy:
		get_viewport().set_input_as_handled()
		return
	match step:
		0:
			if event.is_action_pressed("ui_left"):
				get_viewport().set_input_as_handled()
				handle_step(left_arrow)
		1:
			if event.is_action_pressed("ui_up"):
				get_viewport().set_input_as_handled()
				handle_step(up_arrow)
		2:
			if event.is_action_pressed("ui_right"):
				get_viewport().set_input_as_handled()
				handle_step(right_arrow)
		3:
			if event.is_action_pressed("ui_down"):
				get_viewport().set_input_as_handled()
				handle_step(down_arrow)

func handle_step(tile: TileMapLayer):
	busy = true
	step += 1
	tile.visible = false
	
	await get_tree().create_timer(1.0).timeout
	
	if completed:
		return
	
	if step >= 4:
		completed = true
		busy = false
		GameManager.tutorial_completed = true
		GameManager.save_game()
		emit_signal("tutorial_finished")  # ✅ just emit, no node reference needed
		return
	
	show_current_step()
	busy = false
