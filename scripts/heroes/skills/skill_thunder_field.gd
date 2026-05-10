extends SkillBase
class_name SkillThunderField

@export var radius: float = 4.2
@export var pulse_count: int = 3
@export var pulse_interval: float = 0.32

func _ready() -> void:
    skill_name = "Thunder Field"
    description = "2: Ranged area spell with three thunder pulses."
    cooldown = 4.6
    mana_cost = 30.0
    cast_range = 16.0
    damage = 250.0

func _apply_skill(target: Node3D) -> void:
    var caster: HeroBase = _caster as HeroBase
    if not caster:
        return
    var color: Color = Color(0.45, 0.62, 1.0, 1.0) if caster.get_team() == GameManager.Team.BLUE else Color(1.0, 0.34, 0.15, 1.0)
    var center: Vector3 = caster.global_position + caster.get_facing_direction() * minf(cast_range, 8.0)
    if target and is_instance_valid(target):
        center = target.global_position
    center.y = caster.global_position.y
    if has_node("/root/AudioManager"):
        AudioManager.ultimate(center)
    caster.play_cast_feedback(color, 0.20, 2.2)
    for i in range(pulse_count):
        VFXFactory.spawn_ring(get_tree().current_scene, center + Vector3.UP * 0.08, color, radius * (0.75 + float(i) * 0.13), 0.34)
        VFXFactory.spawn_burst(get_tree().current_scene, center + Vector3.UP * 1.0, color, 20, 0.26)
        _damage_pulse(caster, center, radius, damage + float(i) * 75.0)
        if i < pulse_count - 1:
            await get_tree().create_timer(pulse_interval).timeout

func _damage_pulse(caster: HeroBase, center: Vector3, p_radius: float, dmg: float) -> void:
    for enemy in TeamManager.get_enemies(caster.get_team()):
        if not CombatQueries.is_enemy(enemy, caster.get_team(), caster):
            continue
        if center.distance_to(enemy.global_position) > p_radius:
            continue
        var final_damage: float = DamageSystem.calculate_magic_damage(caster.get_attack_damage() + 150.0, CombatQueries.magic_resistance(enemy), dmg)
        CombatQueries.apply_raw_damage(enemy, final_damage, caster)
