extends CanvasLayer
class_name MainMenu

signal play_pressed
signal settings_pressed
signal quit_pressed

@onready var title_label: Label = $Control/VBoxContainer/TitleLabel
@onready var play_button: Button = $Control/VBoxContainer/PlayButton
@onready var settings_button: Button = $Control/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Control/VBoxContainer/QuitButton
@onready var version_label: Label = $Control/VBoxContainer/VersionLabel

var _settings_instance: Node = null

func _ready() -> void:
    get_tree().paused = false
    title_label.text = "MOBA Arena"
    play_button.pressed.connect(_on_play_pressed)
    settings_button.pressed.connect(_on_settings_pressed)
    quit_button.pressed.connect(_on_quit_pressed)
    version_label.text = "Playable 3D Arena Build"
    GameManager.current_state = GameManager.GameState.MENU

func _on_play_pressed() -> void:
    if _settings_instance and is_instance_valid(_settings_instance):
        _settings_instance.queue_free()
    play_pressed.emit()
    if ResourceLoader.exists("res://scenes/ui/hero_select.tscn"):
        GameManager.current_state = GameManager.GameState.HERO_SELECT
        get_tree().change_scene_to_file("res://scenes/ui/hero_select.tscn")
    else:
        get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed() -> void:
    settings_pressed.emit()
    if _settings_instance and is_instance_valid(_settings_instance):
        _settings_instance.queue_free()
        _settings_instance = null
        return
    _settings_instance = load("res://scenes/ui/settings_ui.tscn").instantiate()
    add_child(_settings_instance)
    _settings_instance.tree_exited.connect(_on_settings_closed)

func _on_settings_closed() -> void:
    _settings_instance = null

func _on_quit_pressed() -> void:
    quit_pressed.emit()
    get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
        if not _settings_instance or not is_instance_valid(_settings_instance):
            _on_play_pressed()
