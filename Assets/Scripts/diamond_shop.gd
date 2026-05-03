extends Control

@onready var diamond_label = %diamond_label

func _ready():
	update_diamonds()
	GameManager.diamonds_changed.connect(_on_diamonds_changed)

func update_diamonds():
	if diamond_label and is_instance_valid(diamond_label):
		diamond_label.text = "" + str(GameManager.get_diamonds())

func _on_diamonds_changed(_amount):
	update_diamonds()

func _on_package_100_pressed():
	GameManager.add_diamonds(100)

func _on_package250_pressed():
	GameManager.add_diamonds(250)

func _on_package500_pressed():
	GameManager.add_diamonds(500)

func _on_package1000_pressed():
	GameManager.add_diamonds(1000)

func _on_cancel_btn_pressed():
	get_tree().change_scene_to_file("res://Assets/Scene/main_island.tscn")
