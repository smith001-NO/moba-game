extends Node
class_name AttackComponent

enum AttackType { MELEE, RANGED }

signal attacked(target: Node, damage: float)
signal cooldown_ready()

@export var attack_type: AttackType = AttackType.MELEE
@export var base_attack_damage: float = 30.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.0
@export var projectile_scene: PackedScene = null
@export var projectile_spawn_path: NodePath = NodePath("")

var is_on_cooldown: bool = false
var _owner: Node = null
var _cooldown_timer: Timer = null

func _ready() -> void:
    _owner = get_parent()
    _cooldown_timer = Timer.new()
    _cooldown_timer.name = "AttackCooldownTimer"
    _cooldown_timer.one_shot = true
    _cooldown_timer.timeout.connect(_on_cooldown_finished)
    add_child(_cooldown_timer)

func attack(target: Node) -> bool:
    if is_on_cooldown or not is_instance_valid(target):
        return false
    if _owner is Node3D and target is Node3D:
        if (_owner as Node3D).global_position.distance_to((target as Node3D).global_position) > attack_range + 0.35:
            return false
    match attack_type:
        AttackType.MELEE:
            _perform_melee_attack(target)
        AttackType.RANGED:
            _perform_ranged_attack(target)
    _start_cooldown()
    return true

func _perform_melee_attack(target: Node) -> void:
    var health: HealthComponent = CombatQueries.health(target)
    if not health:
        return
    var attacker_atk: float = base_attack_damage
    if _owner and _owner.has_method("get_attack_damage"):
        attacker_atk = float(_owner.call("get_attack_damage"))
    var defender_def: float = CombatQueries.defense(target)
    var final_damage: float = DamageSystem.calculate_physical_damage(attacker_atk, defender_def, base_attack_damage)
    if target is Node3D:
        (target as Node3D).set_meta("last_attacker", _owner)
        final_damage = CombatQueries.apply_raw_damage(target as Node3D, final_damage, _owner as Node3D)
    else:
        health.take_raw_damage(final_damage)
    attacked.emit(target, final_damage)

func _perform_ranged_attack(target: Node) -> void:
    if projectile_scene == null:
        _perform_melee_attack(target)
        return
    var spawn_pos = Vector3.ZERO
    if projectile_spawn_path != NodePath("") and has_node(projectile_spawn_path):
        spawn_pos = (get_node(projectile_spawn_path) as Node3D).global_position
    elif _owner is Node3D:
        spawn_pos = (_owner as Node3D).global_position + Vector3.UP
    var target_pos: Vector3 = spawn_pos + Vector3.FORWARD
    if target is Node3D:
        target_pos = (target as Node3D).global_position
    var direction: Vector3 = (target_pos - spawn_pos).normalized()
    var projectile = projectile_scene.instantiate() as Projectile
    get_tree().current_scene.add_child(projectile)
    projectile.owner_team = CombatQueries.team(_owner)
    projectile.attack_stat = base_attack_damage
    if _owner and _owner.has_method("get_attack_damage"):
        projectile.attack_stat = float(_owner.call("get_attack_damage"))
    projectile.damage = base_attack_damage
    projectile.initialize(spawn_pos, direction, _owner)
    attacked.emit(target, base_attack_damage)

func _start_cooldown() -> void:
    is_on_cooldown = true
    _cooldown_timer.start(maxf(attack_cooldown, 0.05))

func _on_cooldown_finished() -> void:
    is_on_cooldown = false
    cooldown_ready.emit()

func get_cooldown_ratio() -> float:
    if not is_on_cooldown:
        return 0.0
    return _cooldown_timer.time_left / maxf(attack_cooldown, 0.05)

func reset_cooldown() -> void:
    _cooldown_timer.stop()
    is_on_cooldown = false
