extends Control

# Island Buttons
@onready var fable_isle_btn = %fableIsle_btn
@onready var countoria_btn = %countoria_btn
@onready var bloom_grove_btn = %bloomGrove_btn
@onready var zypheria_btn = %zypheria_btn

# Lock Images
@onready var fable_lock = %fableLock_btn
@export var count_lock: NinePatchRect
@onready var bloom_lock = %bloomLock_btn
@onready var zyph_lock = %zyphLock_btn

func _ready():
	update_all_locks()
	GameManager.island_unlocked.connect(_on_island_unlocked)
	GameManager.reward_received.connect(_on_reward_received)

func update_all_locks():
	# --- ISLAND 1 (Fable Isle) ---
	# Locked if: NOT unlocked OR already fully done
	var fable_unlocked = GameManager.is_island_unlocked("island_1")
	var fable_done = GameManager.is_island_done("island_1")
	fable_lock.visible = not fable_unlocked or fable_done   # ✅ FIXED: was using count_lock
	fable_isle_btn.disabled = not fable_unlocked or fable_done  # ✅ FIXED: was using countoria_btn

	# --- ISLAND 2 (Countoria) ---
	var count_unlocked = GameManager.is_island_unlocked("island_2")
	var count_done = GameManager.is_island_done("island_2")
	count_lock.visible = not count_unlocked or count_done
	countoria_btn.disabled = not count_unlocked or count_done

	# --- ISLAND 3 (Bloom Grove) ---
	var bloom_unlocked = GameManager.is_island_unlocked("island_3")
	var bloom_done = GameManager.is_island_done("island_3")
	bloom_lock.visible = not bloom_unlocked or bloom_done
	bloom_grove_btn.disabled = not bloom_unlocked or bloom_done

	# --- ISLAND 4 (Zypheria) ---
	var zyph_unlocked = GameManager.is_island_unlocked("island_4")
	var zyph_done = GameManager.is_island_done("island_4")
	zyph_lock.visible = not zyph_unlocked or zyph_done
	zypheria_btn.disabled = not zyph_unlocked or zyph_done

func _on_island_unlocked(_island_name):
	update_all_locks()

func _on_reward_received(_island_name):
	update_all_locks()

# --- Button Pressed Functions ---
func _on_fable_isle_btn_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/FableIsland/fableisland.tscn")

func _on_countoria_btn_pressed():
	if GameManager.is_island_unlocked("island_2") and not GameManager.is_island_done("island_2"):
		get_tree().change_scene_to_file("res://Assets/Scene/Countoria/countoria.tscn")

func _on_bloom_grove_btn_pressed():
	if GameManager.is_island_unlocked("island_3") and not GameManager.is_island_done("island_3"):
		get_tree().change_scene_to_file("res://Assets/Scene/BloomsGrove/science.scn")

func _on_zypheria_btn_pressed():
	if GameManager.is_island_unlocked("island_4") and not GameManager.is_island_done("island_4"):
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
