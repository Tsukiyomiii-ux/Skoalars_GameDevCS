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

func _ready():
	update_shop()
	
	GameManager.diamonds_changed.connect(_on_diamonds_changed)
	GameManager.skill_purchased.connect(_on_skill_bought)
	
	# ✅ PERFECT MATCH - your @onready vars → correct functions
	hint_btn.pressed.connect(_on_hint_purchase_btn_pressed)
	freeze_btn.pressed.connect(_on_freeze_time_purchase_btn_pressed)
	time_btn.pressed.connect(_on_add_time_purchase_btn_pressed)
	skip_btn.pressed.connect(_on_skip_purchase_btn_pressed)

func safe_update_button(btn: Button, text: String, disabled: bool = false):
	if btn and is_instance_valid(btn):
		btn.text = text
		btn.disabled = disabled

func safe_update_count_label(label: Label, count: int):
	if label and is_instance_valid(label):
		label.text = "×" + str(count)  # Nicer "×5" format

func update_shop():
	diamond_label.text = "" + str(GameManager.get_diamonds())
	
	# HINT - Button stays empty, labels show everything
	var hint_uses = GameManager.get_skill_uses("hint")
	hint_btn.disabled = false  # Always clickable
	hint_count_label.text = "×" + str(hint_uses) if GameManager.has_skill("hint") else str(GameManager.get_skill_cost("hint"))

	# FREEZE
	var freeze_uses = GameManager.get_skill_uses("freeze_time")
	freeze_btn.disabled = false
	freeze_count_label.text = "×" + str(freeze_uses) if GameManager.has_skill("freeze_time") else str(GameManager.get_skill_cost("freeze_time"))

	# ADD TIME
	var time_uses = GameManager.get_skill_uses("add_time")
	time_btn.disabled = false
	time_count_label.text = "×" + str(time_uses) if GameManager.has_skill("add_time") else str(GameManager.get_skill_cost("add_time"))

	# SKIP
	var skip_uses = GameManager.get_skill_uses("skip")
	skip_btn.disabled = false
	skip_count_label.text = "×" + str(skip_uses) if GameManager.has_skill("skip") else str(GameManager.get_skill_cost("skip"))
func _on_diamonds_changed(_amount):
	update_shop()

func _on_skill_bought(_skill):
	update_shop()

func _on_skill_uses_changed(_skill: String, _remaining: int):
	update_shop()

# ✅ PURCHASE FUNCTIONS - UNLIMITED!
func _on_hint_purchase_btn_pressed():
	if GameManager.buy_skill("hint"):
		print("✅ Hint +1 use! Total: ", GameManager.get_skill_uses("hint"))

func _on_freeze_time_purchase_btn_pressed():
	if GameManager.buy_skill("freeze_time"):
		print("✅ Freeze +1 use! Total: ", GameManager.get_skill_uses("freeze_time"))

func _on_add_time_purchase_btn_pressed():
	if GameManager.buy_skill("add_time"):
		print("✅ Add Time +1 use! Total: ", GameManager.get_skill_uses("add_time"))

func _on_skip_purchase_btn_pressed():
	if GameManager.buy_skill("skip"):
		print("✅ Skip +1 use! Total: ", GameManager.get_skill_uses("skip"))

func _on_cancel_btn_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/main_island.tscn")
