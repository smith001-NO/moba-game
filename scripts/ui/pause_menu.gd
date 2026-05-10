extends CanvasLayer
class_name PauseMenu

## 暂停菜单
## 按 Escape 暂停游戏并显示菜单

var is_paused = false

@onready var panel: Panel = $Panel
@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

func _ready():
	hide()
	panel.hide()

	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if not is_paused:
			pause_game()
		else:
			resume_game()
		get_viewport().set_input_as_handled()

func pause_game():
	is_paused = true
	show()
	panel.show()
	get_tree().paused = true

func resume_game():
	is_paused = false
	hide()
	panel.hide()
	get_tree().paused = false

func _on_resume_pressed():
	resume_game()

func _on_settings_pressed():
	# 可在此打开设置面板
	var settings = preload("res://scenes/ui/settings_ui.tscn").instantiate()
	add_child(settings)

func _on_quit_pressed():
	resume_game()  # 先恢复
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
