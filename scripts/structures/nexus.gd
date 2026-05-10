extends StaticBody3D
class_name Nexus

@export var team: GameManager.Team = GameManager.Team.BLUE
@export var max_hp: float = 9500.0

var current_hp: float = 0.0
var is_destroyed: bool = false
var _status_label: Label3D = null

@onready var health_component: HealthComponent = $HealthComponent
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
    set_meta("is_nexus", true)
    collision_layer = 2
    collision_mask = 0
    current_hp = max_hp
    health_component.max_hp = max_hp
    health_component.current_hp = max_hp
    health_component.health_changed.connect(_on_health_changed)
    health_component.died.connect(_on_destroyed)
    _create_status_label()
    TeamManager.register_unit(self, team)
    _apply_visual(false)

func _on_health_changed(current: float, _max_hp: float) -> void:
    current_hp = current
    _update_status_label()

func _on_destroyed() -> void:
    if is_destroyed:
        return
    is_destroyed = true
    if has_node("/root/AudioManager"):
        AudioManager.core(global_position)
    TeamManager.unregister_unit(self, team)
    if has_node("/root/EventBus"):
        EventBus.nexus_destroyed.emit(self, team)
    var winner: GameManager.Team = GameManager.Team.RED
    if team != GameManager.Team.BLUE:
        winner = GameManager.Team.BLUE
    var killer: Node3D = get_meta("last_attacker", null) as Node3D
    if killer and killer.has_method("grant_rewards"):
        killer.call("grant_rewards", 760.0, 650, "nexus")
    GameManager.add_score(winner, 25)
    GameManager.end_game(winner)
    collision_layer = 0
    _apply_visual(true)
    _update_status_label()

func get_team() -> GameManager.Team:
    return team

func get_defense() -> float:
    return 65.0

func is_alive() -> bool:
    return not is_destroyed

func _apply_visual(destroyed: bool) -> void:
    var team_color: Color = Color(0.12, 0.48, 1.0, 1.0)
    if team != GameManager.Team.BLUE:
        team_color = Color(1.0, 0.1, 0.08, 1.0)
    for child in get_children():
        if child is MeshInstance3D:
            var mat = StandardMaterial3D.new()
            mat.roughness = 0.45
            if destroyed:
                mat.albedo_color = Color(0.08, 0.08, 0.08, 1.0)
            elif child.name.to_lower().contains("core") or child.name.to_lower().contains("crystal"):
                mat.albedo_color = team_color
                mat.emission_enabled = true
                mat.emission = team_color
                mat.emission_energy_multiplier = 1.3
            else:
                mat.albedo_color = Color(0.35, 0.36, 0.42, 1.0)
            (child as MeshInstance3D).set_surface_override_material(0, mat)

func _create_status_label() -> void:
    _status_label = Label3D.new()
    _status_label.name = "StatusLabel"
    _status_label.position = Vector3(0.0, 5.2, 0.0)
    _status_label.font_size = 28
    add_child(_status_label)
    _update_status_label()

func _update_status_label() -> void:
    if not _status_label:
        return
    _status_label.text = "DESTROYED" if is_destroyed else "BASE\n%.0f/%.0f" % [current_hp, max_hp]
