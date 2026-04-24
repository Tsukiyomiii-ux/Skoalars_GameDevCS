extends Node2D

@export var growth_stage=0

@export var stage_textures:Array[Texture2D] = []

@onready var sprite=$Sprite2D

func _ready():
	stage_textures = [
		load("res://Assets/Bloom Game 1/Plant1_1.png"),
		load("res://Assets/Bloom Game 1/Plant1_2.png"),
		load("res://Assets/Bloom Game 1/Plant1_3.png")
	]

func grow():
	if growth_stage < stage_textures.size() - 1:
			growth_stage += 1
			update_visual()

func update_visual():
		print(stage_textures)
		sprite.texture = stage_textures[growth_stage]


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		await get_tree().create_timer(1.0).timeout
		grow()
