extends Control

# Island Buttons
@onready var fable_isle_btn = %fableIsle_btn
@onready var countoria_btn = %countoria_btn
@onready var bloom_grove_btn = %bloomGrove_btn
@onready var zypheria_btn = %zypheria_btn

# Lock Images (children of each button)
@export var count_lock: NinePatchRect
@onready var bloom_lock = %bloomLock_btn
@onready var zyph_lock = %zyphLock_btn

func _ready():
	update_all_locks()
	GameManager.island_unlocked.connect(_on_island_unlocked)

func update_all_locks():
	count_lock.visible = not GameManager.is_island_unlocked("island_2")
	bloom_lock.visible = not GameManager.is_island_unlocked("island_3")
	zyph_lock.visible = not GameManager.is_island_unlocked("island_4")
	
	# Disable buttons if locked
	countoria_btn.disabled = not GameManager.is_island_unlocked("island_2")
	bloom_grove_btn.disabled = not GameManager.is_island_unlocked("island_3")
	zypheria_btn.disabled = not GameManager.is_island_unlocked("island_4")

func _on_island_unlocked(_island_name):
	update_all_locks()

# --- Button Pressed Functions ---
func _on_fable_isle_btn_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/fableisland.tscn")

func _on_countoria_btn_pressed():
	if GameManager.is_island_unlocked("island_2"):
		get_tree().change_scene_to_file("res://Assets/Scene/Countoria/countoria.tscn")

func _on_bloom_grove_btn_pressed():
	if GameManager.is_island_unlocked("island_3"):
		get_tree().change_scene_to_file("res://Assets/Scene/BloomsGrove/science.scn")

func _on_zypheria_btn_pressed():
	if GameManager.is_island_unlocked("island_4"):
		get_tree().change_scene_to_file("res://Assets/Scene/Zypheria/zypheria.tscn")


func _on_cancel_btn_pressed():
	var island_scenes = {
		"island_1": "res://Assets/Scene/FableIsland/fableisland.tscn",
		"island_2": "res://Assets/Scene/Countoria/countoria.tscn",
		"island_3": "res://Assets/Scene/BloomsGrove/science.scn",
		"island_4": "res://Assets/Scene/Zypheria/zypheria.tscn",
		"island_5": "res://Assets/Scene/MainIsland/main_island.tscn",
	}
	var scene = island_scenes.get(GameManager.get_current_island(), "res://Assets/Scene/MainIsland/main_island.tscn")
	get_tree().change_scene_to_file(scene)
