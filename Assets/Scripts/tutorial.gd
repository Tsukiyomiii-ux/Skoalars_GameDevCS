extends Node2D

@export var left_arrow: TileMapLayer
@export var up_arrow: TileMapLayer
@export var right_arrow: TileMapLayer
@export var down_arrow: TileMapLayer

var step := 0
var busy := false


func _ready():
	hide_all()
	show_current_step()


func hide_all():
	left_arrow.visible = false
	up_arrow.visible = false
	right_arrow.visible = false
	down_arrow.visible = false


func show_current_step():
	match step:
		0:
			left_arrow.visible = true
		1:
			up_arrow.visible = true
		2:
			right_arrow.visible = true
		3:
			down_arrow.visible = true


func _input(event):
	if busy:
		return

	match step:
		0:
			if event.is_action_pressed("ui_left"):
				handle_step(left_arrow)
		1:
			if event.is_action_pressed("ui_up"):
				handle_step(up_arrow)
		2:
			if event.is_action_pressed("ui_right"):
				handle_step(right_arrow)
		3:
			if event.is_action_pressed("ui_down"):
				handle_step(down_arrow)


func handle_step(tile: TileMapLayer):
	busy = true

	await get_tree().create_timer(1.0).timeout
	tile.visible = false

	step += 1

	if step >= 4:
		get_tree().change_scene_to_file("res://Assets/Scene/main_island.tscn")
		return

	show_current_step()
	busy = false
