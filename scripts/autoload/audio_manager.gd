extends Node

var bgm_stream: AudioStream = preload("res://assets/audio/music/xuanhuan_battle_theme.wav")
var hit_sfx: AudioStream = preload("res://assets/audio/sfx/hit.wav")
var skill_sfx: AudioStream = preload("res://assets/audio/sfx/skill_cast.wav")
var heal_sfx: AudioStream = preload("res://assets/audio/sfx/heal.wav")
var death_sfx: AudioStream = preload("res://assets/audio/sfx/death.wav")
var core_sfx: AudioStream = preload("res://assets/audio/sfx/core.wav")
var kill_sfx: AudioStream = preload("res://assets/audio/sfx/kill.wav")
var level_sfx: AudioStream = preload("res://assets/audio/sfx/level_up.wav")
var purchase_sfx: AudioStream = preload("res://assets/audio/sfx/purchase.wav")
var ulti_sfx: AudioStream = preload("res://assets/audio/sfx/ulti.wav")

var _bgm_player: AudioStreamPlayer
var master_volume_db: float = 7.0
var sfx_volume_db: float = 5.0
var music_volume_db: float = 2.0

func _ready() -> void:
    _ensure_audio_buses()
    _bgm_player = AudioStreamPlayer.new()
    _bgm_player.name = "BGMPlayer"
    _bgm_player.volume_db = music_volume_db
    if AudioServer.get_bus_index("Music") >= 0:
        _bgm_player.bus = "Music"
    add_child(_bgm_player)
    _configure_loop(bgm_stream)
    play_bgm(bgm_stream)

func _ensure_audio_buses() -> void:
    if AudioServer.get_bus_index("SFX") < 0:
        AudioServer.add_bus(AudioServer.get_bus_count())
        AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "SFX")
    if AudioServer.get_bus_index("Music") < 0:
        AudioServer.add_bus(AudioServer.get_bus_count())
        AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "Music")

func set_master_linear(value: float) -> void:
    master_volume_db = linear_to_db(clampf(value, 0.001, 1.5))
    var idx := AudioServer.get_bus_index("Master")
    if idx >= 0:
        AudioServer.set_bus_volume_db(idx, master_volume_db)
    if _bgm_player:
        _bgm_player.volume_db = music_volume_db + master_volume_db

func set_sfx_linear(value: float) -> void:
    sfx_volume_db = linear_to_db(clampf(value, 0.001, 1.5)) + 5.0
    var idx := AudioServer.get_bus_index("SFX")
    if idx >= 0:
        AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(value, 0.001, 1.5)))

func set_music_linear(value: float) -> void:
    music_volume_db = linear_to_db(clampf(value, 0.001, 1.5)) + 2.0
    var idx := AudioServer.get_bus_index("Music")
    if idx >= 0:
        AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(value, 0.001, 1.5)))
    if _bgm_player:
        _bgm_player.volume_db = music_volume_db + master_volume_db

func _configure_loop(stream: AudioStream) -> void:
    if stream is AudioStreamWAV:
        (stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD

func play_bgm(stream: AudioStream) -> void:
    if not stream:
        return
    _configure_loop(stream)
    _bgm_player.stream = stream
    _bgm_player.volume_db = music_volume_db + master_volume_db
    _bgm_player.play()

func set_music_volume(db: float) -> void:
    music_volume_db = db
    if _bgm_player:
        _bgm_player.volume_db = music_volume_db + master_volume_db

func play_ui(stream: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
    if not stream:
        return
    var player: AudioStreamPlayer = AudioStreamPlayer.new()
    player.stream = stream
    player.volume_db = volume_db + sfx_volume_db + master_volume_db
    if AudioServer.get_bus_index("SFX") >= 0:
        player.bus = "SFX"
    player.pitch_scale = pitch
    add_child(player)
    player.play()
    player.finished.connect(player.queue_free)

func play_at(stream: AudioStream, pos: Vector3, volume_db: float = 0.0, pitch: float = 1.0) -> void:
    if not stream or not get_tree().current_scene:
        return
    var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
    player.stream = stream
    player.volume_db = volume_db + sfx_volume_db + master_volume_db
    if AudioServer.get_bus_index("SFX") >= 0:
        player.bus = "SFX"
    player.pitch_scale = pitch
    if AudioServer.get_bus_index("SFX") >= 0:
        player.bus = "SFX"
    player.unit_size = 20.0
    player.max_distance = 110.0
    get_tree().current_scene.add_child(player)
    player.global_position = pos
    player.play()
    player.finished.connect(player.queue_free)

func hit(pos: Vector3) -> void:
    play_at(hit_sfx, pos, 0.0, randf_range(0.96, 1.06))

func skill(pos: Vector3) -> void:
    play_at(skill_sfx, pos, 0.5, randf_range(0.94, 1.10))

func heal(pos: Vector3) -> void:
    play_at(heal_sfx, pos, 1.0, randf_range(0.98, 1.08))

func death(pos: Vector3) -> void:
    play_at(death_sfx, pos, 0.0, randf_range(0.92, 1.02))

func core(pos: Vector3) -> void:
    play_at(core_sfx, pos, 1.5, 1.0)

func kill() -> void:
    play_ui(kill_sfx, 2.0, 1.0)

func kill_event(streak: int, revenge: bool = false) -> void:
    var pitch: float = 1.0 + minf(float(max(streak - 1, 0)) * 0.06, 0.28)
    var volume: float = 3.0 if revenge else 2.0 + minf(float(streak) * 0.35, 2.2)
    play_ui(kill_sfx, volume, pitch)

func level_up() -> void:
    play_ui(level_sfx, 2.0, 1.0)

func purchase() -> void:
    play_ui(purchase_sfx, 1.0, 1.0)

func ultimate(pos: Vector3) -> void:
    play_at(ulti_sfx, pos, 2.0, 1.0)
