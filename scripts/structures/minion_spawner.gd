extends Node3D
class_name MinionSpawner

@export var team: GameManager.Team = GameManager.Team.BLUE
@export var spawn_interval: float = 12.0
@export var minions_per_wave: int = 4
@export var minion_scene: PackedScene
@export var initial_delay: float = 1.0

var spawn_timer: float = 0.0
var wave_count: int = 0
var _is_spawning: bool = false

func _ready() -> void:
    if not minion_scene:
        push_error("MinionSpawner: minion_scene missing")
        return
    await get_tree().create_timer(initial_delay).timeout
    if GameManager.current_state == GameManager.GameState.PLAYING:
        _spawn_wave()

func _process(delta: float) -> void:
    if _is_spawning or GameManager.current_state != GameManager.GameState.PLAYING:
        return
    spawn_timer += delta
    if spawn_timer >= spawn_interval:
        spawn_timer = 0.0
        _spawn_wave()

func _spawn_wave() -> void:
    if _is_spawning or not minion_scene:
        return
    _is_spawning = true
    wave_count += 1
    var parent = get_tree().current_scene
    for i in range(minions_per_wave):
        var minion = minion_scene.instantiate() as Minion
        minion.team = team
        _apply_wave_scaling(minion)
        parent.add_child(minion)
        var lane_side: float = -1.0
        if i % 2 != 0:
            lane_side = 1.0
        var row = float(i / 2)
        var x_offset: float = -row * 0.8
        if team != GameManager.Team.BLUE:
            x_offset = row * 0.8
        var offset: Vector3 = Vector3(x_offset, 0.0, lane_side * (0.9 + row * 0.35))
        minion.global_position = Vector3(global_position.x + offset.x, 0.65, global_position.z + offset.z)
        if i < minions_per_wave - 1:
            await get_tree().create_timer(0.18).timeout
    _is_spawning = false


func _apply_wave_scaling(minion: Minion) -> void:
    if not minion:
        return
    var tier: int = int(max(0, wave_count - 1) / 5)
    if tier <= 0:
        return
    minion.max_hp += float(tier) * 110.0
    minion.attack_damage += float(tier) * 9.0
    minion.move_speed += min(float(tier) * 0.06, 0.45)
    minion.scale *= 1.0 + min(float(tier) * 0.035, 0.18)
