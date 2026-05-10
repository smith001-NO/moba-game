extends CanvasLayer
class_name SettingsUI

@onready var panel: Panel = $Panel
@onready var master_volume: HSlider = $Panel/MarginContainer/VBoxContainer/AudioSection/MasterVolume
@onready var sfx_volume: HSlider = $Panel/MarginContainer/VBoxContainer/AudioSection/SFXVolume
@onready var music_volume: HSlider = $Panel/MarginContainer/VBoxContainer/AudioSection/MusicVolume
@onready var fullscreen_check: CheckBox = $Panel/MarginContainer/VBoxContainer/VideoSection/FullscreenCheck
@onready var back_button: Button = $Panel/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _ensure_audio_buses()
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    master_volume.value = _get_volume("Master")
    sfx_volume.value = _get_volume("SFX")
    music_volume.value = _get_volume("Music")
    fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

    if not master_volume.value_changed.is_connected(_on_master_volume_changed):
        master_volume.value_changed.connect(_on_master_volume_changed)
    if not sfx_volume.value_changed.is_connected(_on_sfx_volume_changed):
        sfx_volume.value_changed.connect(_on_sfx_volume_changed)
    if not music_volume.value_changed.is_connected(_on_music_volume_changed):
        music_volume.value_changed.connect(_on_music_volume_changed)
    if not fullscreen_check.toggled.is_connected(_on_fullscreen_toggled):
        fullscreen_check.toggled.connect(_on_fullscreen_toggled)
    if not back_button.pressed.is_connected(_on_back_pressed):
        back_button.pressed.connect(_on_back_pressed)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            _on_back_pressed()

func _ensure_audio_buses() -> void:
    if AudioServer.get_bus_index("SFX") < 0:
        AudioServer.add_bus(AudioServer.get_bus_count())
        AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "SFX")
    if AudioServer.get_bus_index("Music") < 0:
        AudioServer.add_bus(AudioServer.get_bus_count())
        AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "Music")

func _get_volume(bus_name: String) -> float:
    var bus_idx: int = AudioServer.get_bus_index(bus_name)
    if bus_idx < 0:
        return 1.0
    return clampf(db_to_linear(AudioServer.get_bus_volume_db(bus_idx)), 0.0, 1.0)

func _apply_bus_volume(bus_name: String, value: float) -> void:
    var bus_idx: int = AudioServer.get_bus_index(bus_name)
    if bus_idx >= 0:
        AudioServer.set_bus_volume_db(bus_idx, linear_to_db(clampf(value, 0.001, 1.0)))

func _on_master_volume_changed(value: float) -> void:
    _apply_bus_volume("Master", value)
    if has_node("/root/AudioManager") and AudioManager.has_method("set_master_linear"):
        AudioManager.set_master_linear(value)

func _on_sfx_volume_changed(value: float) -> void:
    _apply_bus_volume("SFX", value)
    if has_node("/root/AudioManager") and AudioManager.has_method("set_sfx_linear"):
        AudioManager.set_sfx_linear(value)

func _on_music_volume_changed(value: float) -> void:
    _apply_bus_volume("Music", value)
    if has_node("/root/AudioManager") and AudioManager.has_method("set_music_linear"):
        AudioManager.set_music_linear(value)

func _on_fullscreen_toggled(toggled: bool) -> void:
    # 避免旧实现在某些窗口管理器下频繁切换造成假死；延迟一帧执行。
    call_deferred("_apply_fullscreen", toggled)

func _apply_fullscreen(toggled: bool) -> void:
    if toggled:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_pressed() -> void:
    queue_free()
