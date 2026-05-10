extends SkillBase
class_name SkillHeal

@export var heal_amount: float = 680.0
@export var pulse_damage: float = 210.0

func _ready() -> void:
    skill_name = "Renewal Field"
    description = "R: Heal yourself and pulse damage around you."
    cooldown = 5.5
    mana_cost = 24.0
    cast_range = 0.0
    damage = 0.0

func _apply_skill(_target: Node3D) -> void:
    var caster: HeroBase = _caster as HeroBase
    if not caster:
        return
    var color: Color = Color(0.24, 1.0, 0.46, 1.0)
    caster.heal(heal_amount + float(caster.level) * 95.0)
    if has_node("/root/AudioManager"):
        AudioManager.heal(caster.global_position)
    caster.play_cast_feedback(color, 0.24)
    VFXFactory.spawn_ring(get_tree().current_scene, caster.global_position + Vector3.UP * 0.08, color, 2.8, 0.58)
    VFXFactory.spawn_burst(get_tree().current_scene, caster.global_position + Vector3.UP * 1.1, color, 20, 0.48)
    for enemy in TeamManager.get_enemies(caster.get_team()):
        if not CombatQueries.is_enemy(enemy, caster.get_team(), caster):
            continue
        if caster.global_position.distance_to(enemy.global_position) <= 3.4:
            CombatQueries.apply_raw_damage(enemy, DamageSystem.calculate_magic_damage(caster.get_attack_damage(), CombatQueries.magic_resistance(enemy), pulse_damage), caster)
