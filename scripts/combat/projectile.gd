extends Area3D
class_name Projectile

signal hit_target(body: Node, damage: float)
signal destroyed()

@export var speed: float = 24.0
@export var damage: float = 90.0
@export var max_distance: float = 24.0
@export var owner_team: int = GameManager.Team.NEUTRAL
@export var damage_type: DamageSystem.DamageType = DamageSystem.DamageType.MAGIC
@export var attack_stat: float = 100.0
@export var pierce_count: int = 0
@export var trail_color: Color = Color(1.0, 0.45, 0.08, 1.0)
@export var trail_interval: float = 0.035

var attacker: Node = null
var target_node: Node3D = null
var lock_on_target: bool = false
@export var impact_radius: float = 0.72
var _distance_traveled: float = 0.0
var _direction: Vector3 = Vector3.FORWARD
var _hit_bodies: Array[Node] = []
var _trail_timer: float = 0.0

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)
    _tint_projectile(trail_color)

func _physics_process(delta: float) -> void:
    if lock_on_target:
        if not target_node or not is_instance_valid(target_node) or not CombatQueries.is_alive(target_node):
            destroy()
            return
        var target_pos: Vector3 = target_node.global_position + Vector3.UP * 0.95
        var to_target: Vector3 = target_pos - global_position
        if to_target.length() <= impact_radius:
            _hit_target_node(target_node)
            return
        _direction = to_target.normalized()
        if _direction.length() > 0.01:
            look_at(global_position + _direction, Vector3.UP)
    var step: Vector3 = _direction * speed * delta
    global_position += step
    _distance_traveled += step.length()
    _trail_timer -= delta
    if _trail_timer <= 0.0:
        _trail_timer = trail_interval
        VFXFactory.spawn_projectile_trail(get_tree().current_scene, global_position, trail_color, 0.24)
    if _distance_traveled >= max_distance:
        destroy()

func initialize(origin: Vector3, direction: Vector3, p_attacker: Node = null) -> void:
    global_position = origin
    _direction = direction.normalized() if direction.length() > 0.01 else Vector3.FORWARD
    attacker = p_attacker
    target_node = null
    lock_on_target = false
    _distance_traveled = 0.0
    _hit_bodies.clear()
    _trail_timer = 0.0
    if _direction.length() > 0.01:
        look_at(global_position + _direction, Vector3.UP)

func initialize_target(origin: Vector3, target: Node3D, p_attacker: Node = null) -> void:
    target_node = target
    lock_on_target = true
    var target_pos: Vector3 = origin + Vector3.FORWARD
    if target and is_instance_valid(target):
        target_pos = target.global_position + Vector3.UP * _target_hit_height(target)
    initialize(origin, (target_pos - origin).normalized(), p_attacker)
    target_node = target
    lock_on_target = true

func _target_hit_height(target: Node3D) -> float:
    if not target:
        return 0.8
    if target.has_meta("is_tower"):
        return 2.0
    if target.has_meta("is_nexus"):
        return 2.2
    if target.has_meta("is_minion"):
        return 0.55
    return 1.15

func _hit_target_now(target: Node3D) -> void:
    if not target or not is_instance_valid(target):
        destroy()
        return
    if _hit_bodies.has(target):
        return
    _on_body_entered(target)

func _on_body_entered(body: Node) -> void:
    if body is Node3D:
        _hit_target_node(body as Node3D)

func _hit_target_node(target_body: Node3D) -> void:
    if target_body == null or target_body == attacker or target_body == self or _hit_bodies.has(target_body):
        return
    if CombatQueries.team(target_body) == owner_team:
        return
    if not CombatQueries.is_alive(target_body):
        return
    _hit_bodies.append(target_body)
    var health: HealthComponent = CombatQueries.health(target_body)
    if health:
        target_body.set_meta("last_attacker", attacker)
        var defense: float = _get_defense_stat(target_body, damage_type)
        var calculated_damage: float = DamageSystem.calculate_damage(attack_stat, defense, damage, damage_type)
        var final_damage: float = CombatQueries.apply_raw_damage(target_body, calculated_damage, attacker as Node3D)
        hit_target.emit(target_body, final_damage)
        if get_tree().current_scene:
            VFXFactory.spawn_burst(get_tree().current_scene, target_body.global_position + Vector3.UP * 0.85, trail_color, 10, 0.25)
            VFXFactory.spawn_floating_text(get_tree().current_scene, target_body.global_position + Vector3.UP * 1.65, "-%.0f" % final_damage, Color(1.0, 0.78, 0.32, 1.0))
    if pierce_count > 0:
        pierce_count -= 1
        if pierce_count <= 0:
            destroy()
    else:
        destroy()

func _on_area_entered(_area: Area3D) -> void:
    pass

func destroy() -> void:
    destroyed.emit()
    queue_free()

func _get_defense_stat(body: Node, dmg_type: DamageSystem.DamageType) -> float:
    match dmg_type:
        DamageSystem.DamageType.PHYSICAL:
            return CombatQueries.defense(body)
        DamageSystem.DamageType.MAGIC:
            return CombatQueries.magic_resistance(body)
        _:
            return 0.0

func _tint_projectile(color: Color) -> void:
    for child in get_children():
        if child is MeshInstance3D:
            var mat: StandardMaterial3D = StandardMaterial3D.new()
            mat.albedo_color = color
            mat.emission_enabled = true
            mat.emission = color
            mat.emission_energy_multiplier = 1.7
            mat.roughness = 0.2
            (child as MeshInstance3D).set_surface_override_material(0, mat)
        elif child is OmniLight3D:
            (child as OmniLight3D).light_color = color
