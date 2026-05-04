extends Control

# Equip buttons (EQUIP state)
@onready var hint_equip_btn = %hint_equip_btn
@onready var add_equip_btn = %add_equip_btn
@onready var freeze_equip_btn = %freeze_equip_btn
@onready var skip_equip_btn = %skip_equip_btn

# Unequip buttons (EQUIPPED state)
@onready var hint_lock_btn = %hint_unequip_btn
@onready var add_lock_btn = %add_unequip_btn
@onready var freeze_lock_btn = %freeze_unequip_btn
@onready var skip_lock_btn = %skip_unequip_btn

# Disabled images
@onready var hint_disabled = %hint_disabled
@onready var add_disabled = %add_disabled
@onready var freeze_disabled = %freeze_disabled
@onready var skip_disabled = %skip_disabled

# Count labels
@onready var hint_count_label = %hintCountlabel
@onready var add_count_label = %addCountlabel
@onready var freeze_count_label = %freezeCountlabel
@onready var skip_count_label = %skipCountlabel

func _ready():
	hint_equip_btn.pressed.connect(_on_hint_equip_pressed)
	add_equip_btn.pressed.connect(_on_add_equip_pressed)
	freeze_equip_btn.pressed.connect(_on_freeze_equip_pressed)
	skip_equip_btn.pressed.connect(_on_skip_equip_pressed)
	hint_lock_btn.pressed.connect(_on_hint_unequip_pressed)
	add_lock_btn.pressed.connect(_on_add_unequip_pressed)
	freeze_lock_btn.pressed.connect(_on_freeze_unequip_pressed)
	skip_lock_btn.pressed.connect(_on_skip_unequip_pressed)
	update_all()

func update_all():
	update_skill_row(hint_equip_btn, hint_lock_btn, hint_disabled, hint_count_label, "hint")
	update_skill_row(add_equip_btn, add_lock_btn, add_disabled, add_count_label, "add_time")
	update_skill_row(freeze_equip_btn, freeze_lock_btn, freeze_disabled, freeze_count_label, "freeze_time")
	update_skill_row(skip_equip_btn, skip_lock_btn, skip_disabled, skip_count_label, "skip")

func update_skill_row(equip_btn: Button, lock_btn: Button, disabled_img: Node, count_lbl: Label, skill_name: String):
	var owned = GameManager.has_skill(skill_name)
	var equipped = GameManager.is_skill_equipped(skill_name)
	var uses = GameManager.get_skill_uses(skill_name)

	if not owned:
		# Not owned — hide everything
		equip_btn.visible = false
		lock_btn.visible = false
		disabled_img.visible = false
	elif uses <= 0:
		# No uses left — show disabled image, hide both buttons
		equip_btn.visible = false
		lock_btn.visible = false
		disabled_img.visible = true
	elif equipped:
		# Equipped — show unequip button only
		equip_btn.visible = false
		lock_btn.visible = true
		disabled_img.visible = false
	else:
		# Owned, has uses, not equipped — show equip button
		equip_btn.visible = true
		lock_btn.visible = false
		disabled_img.visible = false

	if count_lbl and is_instance_valid(count_lbl):
		count_lbl.text = "×" + str(uses) if owned else "?"

# --- EQUIP HANDLERS ---
func _on_hint_equip_pressed():
	GameManager.equip_skill("hint")
	update_all()

func _on_add_equip_pressed():
	GameManager.equip_skill("add_time")
	update_all()

func _on_freeze_equip_pressed():
	GameManager.equip_skill("freeze_time")
	update_all()

func _on_skip_equip_pressed():
	GameManager.equip_skill("skip")
	update_all()

# --- UNEQUIP HANDLERS ---
func _on_hint_unequip_pressed():
	GameManager.equip_skill("hint")
	update_all()

func _on_add_unequip_pressed():
	GameManager.equip_skill("add_time")
	update_all()

func _on_freeze_unequip_pressed():
	GameManager.equip_skill("freeze_time")
	update_all()

func _on_skip_unequip_pressed():
	GameManager.equip_skill("skip")
	update_all()

func _on_cancel_btn_pressed():
	var island_scenes = {
		"island_1": "res://Assets/Scene/fableIsland.tscn",
		"island_2": "res://Assets/Scene/countoria.tscn",
		"island_3": "res://Assets/Scene/bloom_grove.tscn",
		"island_4": "res://Assets/Scene/zypheria.tscn",
		"island_5": "res://Assets/Scene/main_island.tscn",
	}
	var scene = island_scenes.get(GameManager.get_current_island(), "res://Assets/Scene/main_island.tscn")
	get_tree().change_scene_to_file(scene)
