extends StaticBody3D
class_name Tower

@export var team: GameManager.Team = GameManager.Team.BLUE
@export var max_hp: float = 5200.0
@export var attack_damage: float = 135.0
@export var attack_range: float = 11.5
@export var attack_speed: float = 0.8
@export var detection_range: float = 12.0

var current_hp: float = 0.0
var is_destroyed: bool = false
var current_target: Node3D = null
var attack_cooldown: float = 0.0
var _status_label: Label3D = null

@onready var health_component: HealthComponent = $HealthComponent
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
    set_meta("is_tower", true)
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

func _process(delta: float) -> void:
    if is_destroyed or GameManager.current_state != GameManager.GameState.PLAYING:
        return
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    _find_and_attack_enemy()
    _update_status_label()

func _find_and_attack_enemy() -> void:
    if current_target and (not is_instance_valid(current_target) or (current_target.has_method("is_alive") and not current_target.is_alive())):
        current_target = null
    if not current_target or global_position.distance_to(current_target.global_position) > detection_range:
        current_target = _pick_target()
    if current_target and attack_cooldown <= 0.0:
        if global_position.distance_to(current_target.global_position) <= attack_range:
            _attack_target(current_target)
            attack_cooldown = 1.0 / maxf(attack_speed, 0.1)

func _pick_target() -> Node3D:
    var nearest_hero: Node3D = null
    var nearest_minion: Node3D = null
    var nearest_other: Node3D = null
    var hero_dist = detection_range
    var minion_dist = detection_range
    var other_dist = detection_range
    for enemy in TeamManager.get_enemies(team):
        if not is_instance_valid(enemy):
            continue
        if enemy.has_method("is_alive") and not enemy.is_alive():
            continue
        var dist = global_position.distance_to(enemy.global_position)
        if dist > detection_range:
            continue
        if enemy.has_meta("is_hero"):
            if dist < hero_dist:
                hero_dist = dist
                nearest_hero = enemy
        elif enemy.has_meta("is_minion"):
            if dist < minion_dist:
                minion_dist = dist
                nearest_minion = enemy
        elif dist < other_dist:
            other_dist = dist
            nearest_other = enemy
    # More MOBA-like protection pressure: heroes inside tower range are threatening targets.
    return nearest_hero if nearest_hero else (nearest_minion if nearest_minion else nearest_other)

func _attack_target(target: Node3D) -> void:
    target.set_meta("last_attacker", self)
    var health = target.get_node_or_null("HealthComponent") as HealthComponent
    var defense: float = CombatQueries.defense(target)
    var damage: float = DamageSystem.calculate_physical_damage(100.0, defense, attack_damage)
    if health:
        CombatQueries.apply_raw_damage(target, damage, self)
    elif target.has_method("take_damage"):
        target.take_damage(damage, self)
    if has_node("/root/EventBus"):
        EventBus.skill_cast.emit(self, "tower_shot")

func _on_health_changed(current: float, _max_hp: float) -> void:
    current_hp = current

func _on_destroyed() -> void:
    if is_destroyed:
        return
    is_destroyed = true
    TeamManager.unregister_unit(self, team)
    if has_node("/root/EventBus"):
        EventBus.tower_destroyed.emit(self, team)
    var killer: Node3D = get_meta("last_attacker", null) as Node3D
    if killer:
        GameManager.add_score(CombatQueries.team(killer), 5)
        if killer.has_method("grant_rewards"):
            killer.call("grant_rewards", 400.0, 350, "tower")
    collision_layer = 0
    if has_node("/root/AudioManager"):
        AudioManager.core(global_position)
    _apply_visual(true)
    _update_status_label()

func get_team() -> GameManager.Team:
    return team

func get_defense() -> float:
    return 75.0

func is_alive() -> bool:
    return not is_destroyed

func _apply_visual(destroyed: bool) -> void:
    var team_color: Color = Color(0.1, 0.38, 1.0, 1.0)
    if team != GameManager.Team.BLUE:
        team_color = Color(1.0, 0.12, 0.08, 1.0)
    for child in get_children():
        if child is MeshInstance3D:
            var mat = StandardMaterial3D.new()
            mat.roughness = 0.58
            mat.albedo_color = Color(0.25, 0.25, 0.25, 1.0) if destroyed else team_color
            if child.name.to_lower().contains("stone"):
                mat.albedo_color = Color(0.38, 0.38, 0.42, 1.0) if not destroyed else Color(0.2, 0.2, 0.2, 1.0)
            (child as MeshInstance3D).set_surface_override_material(0, mat)

func _create_status_label() -> void:
    _status_label = Label3D.new()
    _status_label.name = "StatusLabel"
    _status_label.position = Vector3(0.0, 4.1, 0.0)
    _status_label.font_size = 24
    add_child(_status_label)
    _update_status_label()

func _update_status_label() -> void:
    if not _status_label:
        return
    _status_label.text = "RUINED" if is_destroyed else "TOWER\n%.0f/%.0f" % [current_hp, max_hp]
