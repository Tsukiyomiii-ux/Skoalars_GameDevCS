extends MarginContainer

@export var Setting_Menu: MarginContainer
@export var Exit: MarginContainer

func toggle_visibility(object):
	if object.visible:
		object.visible = false
	else:
		object.visible = true


func _on_settings_btn_pressed():
	toggle_visibility(Setting_Menu)
	toggle_visibility(Exit)


func _on_ext_btn_pressed():
	toggle_visibility(Setting_Menu)
	toggle_visibility(Exit)
