extends CharacterBody3D
class_name Minion

@export var team: GameManager.Team = GameManager.Team.BLUE
@export var move_speed: float = 3.0
@export var max_hp: float = 650.0
@export var attack_damage: float = 42.0
@export var attack_range: float = 1.8
@export var attack_speed: float = 0.78
@export var detection_range: float = 8.0

var is_dead: bool = false
var current_target: Node3D = null
var _status_label: Label3D = null
var _spawn_position: Vector3 = Vector3.ZERO

@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $AttackComponent

func _ready() -> void:
    set_meta("is_minion", true)
    _spawn_position = global_position
    health_component.max_hp = max_hp
    health_component.current_hp = max_hp
    health_component.died.connect(_on_died)
    attack_component.base_attack_damage = attack_damage
    attack_component.attack_range = attack_range
    attack_component.attack_cooldown = 1.0 / maxf(attack_speed, 0.1)
    _apply_team_visual()
    _create_status_label()
    TeamManager.register_unit(self, team)

func _physics_process(delta: float) -> void:
    if is_dead or GameManager.current_state != GameManager.GameState.PLAYING:
        return
    _select_target()
    if current_target:
        _move_or_attack_target(delta)
    else:
        _push_lane(delta)
    _update_status_label()

func _select_target() -> void:
    if current_target and is_instance_valid(current_target):
        if current_target.has_method("is_alive") and current_target.is_alive():
            if global_position.distance_to(current_target.global_position) < detection_range * 1.7:
                return
    current_target = null
    var nearest: Node3D = null
    var min_dist = detection_range
    for enemy in TeamManager.get_enemies(team):
        if not is_instance_valid(enemy):
            continue
        if enemy.has_method("is_alive") and not enemy.is_alive():
            continue
        var dist = global_position.distance_to(enemy.global_position)
        var priority_bonus: float = 0.0
        if enemy.has_meta("is_minion"):
            priority_bonus = 2.0
        var score_dist = dist - priority_bonus
        if dist < detection_range and score_dist < min_dist:
            min_dist = score_dist
            nearest = enemy
    current_target = nearest

func _move_or_attack_target(delta: float) -> void:
    if not current_target or not is_instance_valid(current_target):
        current_target = null
        return
    var dist = global_position.distance_to(current_target.global_position)
    if dist <= attack_range:
        velocity.x = 0.0
        velocity.z = 0.0
        if attack_component and not attack_component.is_on_cooldown:
            attack_component.attack(current_target)
        _look_toward(current_target.global_position - global_position)
    else:
        _move_toward(current_target.global_position, delta)

func _push_lane(delta: float) -> void:
    var game_map = _get_game_map()
    var target: Vector3 = Vector3(42, global_position.y, 0)
    if team != GameManager.Team.BLUE:
        target = Vector3(-42, global_position.y, 0)
    if game_map:
        target = game_map.get_red_spawn_position() if team == GameManager.Team.BLUE else game_map.get_blue_spawn_position()
        target.y = global_position.y
    _move_toward(target, delta)

func _move_toward(target: Vector3, delta: float) -> void:
    var dir = target - global_position
    dir.y = 0.0
    if dir.length() <= 0.1:
        velocity.x = 0.0
        velocity.z = 0.0
        return
    dir = dir.normalized()
    velocity.x = dir.x * move_speed
    velocity.z = dir.z * move_speed
    if not is_on_floor():
        velocity.y -= 18.0 * delta
    else:
        velocity.y = -0.1
    move_and_slide()
    _look_toward(dir)

func _look_toward(dir: Vector3) -> void:
    dir.y = 0.0
    if dir.length() > 0.01:
        look_at(global_position + dir.normalized(), Vector3.UP, true)

func _on_died() -> void:
    if is_dead:
        return
    is_dead = true
    if has_node("/root/AudioManager"):
        AudioManager.death(global_position)
    var killer = get_meta("last_attacker", null) as Node3D
    if has_node("/root/EventBus"):
        EventBus.unit_died.emit(self, killer)
        if killer:
            EventBus.minion_killed.emit(self, killer)
    if killer:
        GameManager.add_score(CombatQueries.team(killer), 1)
        if killer.has_method("grant_rewards"):
            killer.call("grant_rewards", 120.0, 90, "minion")
    TeamManager.unregister_unit(self, team)
    collision_layer = 0
    visible = false
    await get_tree().create_timer(1.2).timeout
    queue_free()

func get_attack_damage() -> float:
    return attack_damage

func get_defense() -> float:
    return 2.0

func get_team() -> GameManager.Team:
    return team

func is_alive() -> bool:
    return not is_dead and health_component and not health_component.is_dead

func _get_game_map() -> GameMap:
    return get_tree().get_first_node_in_group("game_map") as GameMap

func _apply_team_visual() -> void:
    var team_color: Color = Color(0.22, 0.55, 1.0, 1.0)
    if team != GameManager.Team.BLUE:
        team_color = Color(1.0, 0.25, 0.18, 1.0)
    for mesh in _get_meshes(self):
        var mat = StandardMaterial3D.new()
        mat.roughness = 0.6
        if mesh.name.to_lower().contains("weapon"):
            mat.albedo_color = Color(0.68, 0.68, 0.72, 1.0)
            mat.metallic = 0.25
        else:
            mat.albedo_color = team_color
        mesh.set_surface_override_material(0, mat)

func _get_meshes(node: Node) -> Array[MeshInstance3D]:
    var meshes: Array[MeshInstance3D] = []
    for child in node.get_children():
        if child is MeshInstance3D:
            meshes.append(child)
        meshes.append_array(_get_meshes(child))
    return meshes

func _create_status_label() -> void:
    _status_label = Label3D.new()
    _status_label.name = "StatusLabel"
    _status_label.position = Vector3(0.0, 1.45, 0.0)
    _status_label.font_size = 18
    add_child(_status_label)
    _update_status_label()

func _update_status_label() -> void:
    if not _status_label or not health_component:
        return
    _status_label.text = "%.0f" % health_component.current_hp
