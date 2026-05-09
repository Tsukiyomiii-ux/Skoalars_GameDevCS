extends Control

@onready var diamond_label = %diamond_label
@onready var hint_btn = %hint_purchase_btn
@onready var hint_count_label = %hintCountlabel
@onready var freeze_btn = %freezeTime_purchase_btn
@onready var freeze_count_label = %freezeCountlabel
@onready var time_btn = %addTime_purchase_btn
@onready var time_count_label = %timeCountlabel
@onready var skip_btn = %skip_purchase_btn
@onready var skip_count_label = %skipCountlabel

# Timer Labels
@onready var hint_timer_lbl = %hintTimer_lbl
@onready var freeze_timer_lbl = %freezeTimer_lbl
@onready var time_timer_lbl = %addTimer_lbl
@onready var skip_timer_lbl = %skipTimer_lbl

# --- COOLDOWN APPEARANCE ---
@export var cooldown_font_color: Color = Color(1, 1, 1, 1)

const COOLDOWN_SECONDS = 10.0 #1800.0  # 30 minutes

var last_bought = {
	"hint": 0,
	"freeze_time": 0,
	"add_time": 0,
	"skip": 0
}

func _ready():
	update_shop()
	GameManager.diamonds_changed.connect(_on_diamonds_changed)
	GameManager.skill_purchased.connect(_on_skill_bought)
	hint_btn.pressed.connect(_on_hint_purchase_btn_pressed)
	freeze_btn.pressed.connect(_on_freeze_time_purchase_btn_pressed)
	time_btn.pressed.connect(_on_add_time_purchase_btn_pressed)
	skip_btn.pressed.connect(_on_skip_purchase_btn_pressed)
	
	# Hide all timer labels at start
	hint_timer_lbl.visible = false
	freeze_timer_lbl.visible = false
	time_timer_lbl.visible = false
	skip_timer_lbl.visible = false

func _process(_delta):
	update_cooldown_buttons()

func get_cooldown_remaining(skill_name: String) -> float:
	var elapsed = Time.get_unix_time_from_system() - last_bought[skill_name]
	return max(0.0, COOLDOWN_SECONDS - elapsed)

func is_on_cooldown(skill_name: String) -> bool:
	return get_cooldown_remaining(skill_name) > 0.0

func format_cooldown(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]

func _update_skill_button(btn: Button, skill_name: String, timer_lbl: Label):
	if not btn or not is_instance_valid(btn):
		return
	if is_on_cooldown(skill_name):
		btn.disabled = true
		timer_lbl.visible = true
		timer_lbl.text = format_cooldown(get_cooldown_remaining(skill_name))
		timer_lbl.add_theme_color_override("font_color", cooldown_font_color)
	else:
		btn.disabled = false
		timer_lbl.visible = false
		timer_lbl.text = ""

func update_cooldown_buttons():
	_update_skill_button(hint_btn, "hint", hint_timer_lbl)
	_update_skill_button(freeze_btn, "freeze_time", freeze_timer_lbl)
	_update_skill_button(time_btn, "add_time", time_timer_lbl)
	_update_skill_button(skip_btn, "skip", skip_timer_lbl)

func update_shop():
	diamond_label.text = "" + str(GameManager.get_diamonds())

	var hint_uses = GameManager.get_skill_uses("hint")
	hint_count_label.text = "×" + str(hint_uses) if GameManager.has_skill("hint") else str(GameManager.get_skill_cost("hint"))

	var freeze_uses = GameManager.get_skill_uses("freeze_time")
	freeze_count_label.text = "×" + str(freeze_uses) if GameManager.has_skill("freeze_time") else str(GameManager.get_skill_cost("freeze_time"))

	var time_uses = GameManager.get_skill_uses("add_time")
	time_count_label.text = "×" + str(time_uses) if GameManager.has_skill("add_time") else str(GameManager.get_skill_cost("add_time"))

	var skip_uses = GameManager.get_skill_uses("skip")
	skip_count_label.text = "×" + str(skip_uses) if GameManager.has_skill("skip") else str(GameManager.get_skill_cost("skip"))

func _on_diamonds_changed(_amount):
	update_shop()

func _on_skill_bought(_skill):
	update_shop()

func _on_skill_uses_changed(_skill: String, _remaining: int):
	update_shop()

# --- PURCHASE FUNCTIONS ---
func _on_hint_purchase_btn_pressed():
	if is_on_cooldown("hint"):
		return
	if GameManager.buy_skill("hint"):
		last_bought["hint"] = Time.get_unix_time_from_system()
		print("✅ Hint +1 use! Total: ", GameManager.get_skill_uses("hint"))

func _on_freeze_time_purchase_btn_pressed():
	if is_on_cooldown("freeze_time"):
		return
	if GameManager.buy_skill("freeze_time"):
		last_bought["freeze_time"] = Time.get_unix_time_from_system()
		print("✅ Freeze +1 use! Total: ", GameManager.get_skill_uses("freeze_time"))

func _on_add_time_purchase_btn_pressed():
	if is_on_cooldown("add_time"):
		return
	if GameManager.buy_skill("add_time"):
		last_bought["add_time"] = Time.get_unix_time_from_system()
		print("✅ Add Time +1 use! Total: ", GameManager.get_skill_uses("add_time"))

func _on_skip_purchase_btn_pressed():
	if is_on_cooldown("skip"):
		return
	if GameManager.buy_skill("skip"):
		last_bought["skip"] = Time.get_unix_time_from_system()
		print("✅ Skip +1 use! Total: ", GameManager.get_skill_uses("skip"))

func _on_cancel_btn_pressed():
	var island_scenes = {
		"island_1": "res://Assets/Scene/FableIsland/fableisland.tscn",
		"island_1.1": "res://Assets/Scene/FableIsland/level_1_maze.tscn",
		"island_1.2": "res://Assets/Scene/FableIsland/level_2_spelling_quest.tscn",
		"island_2": "res://Assets/Scene/Countoria/countoria.tscn",
		"island_2.1": "res://Assets/Scene/Countoria/level_1_countoria.tscn",
		"island_2.2": "res://Assets/Scene/Countoria/level_2_countoria.tscn",
		"island_3": "res://Assets/Scene/BloomsGrove/science.scn",
		"island_3.1": "res://Assets/Scene/BloomsGrove/GardenMiniGame.tscn",
		"island_4": "res://Assets/Scene/Zypheria/zypheria.tscn",
		"island_5": "res://Assets/Scene/MainIsland/main_island.tscn",
		
	}
	var scene = island_scenes.get(GameManager.get_current_island(), "res://Assets/Scene/MainIsland/main_island.tscn")
	get_tree().change_scene_to_file(scene)
