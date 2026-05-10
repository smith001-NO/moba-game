extends SkillBase
class_name SkillMeleeSlash

func _ready() -> void:
    skill_name = "Crescent Slash"
    description = "1: Close-range cone slash that hits all enemies in front."
    cooldown = 1.9
    mana_cost = 12.0
    cast_range = 3.7
    damage = 360.0

func _apply_skill(_target: Node3D) -> void:
    var caster: HeroBase = _caster as HeroBase
    if not caster:
        return
    var color: Color = Color(0.72, 0.92, 1.0, 1.0) if caster.get_team() == GameManager.Team.BLUE else Color(1.0, 0.44, 0.22, 1.0)
    if has_node("/root/AudioManager"):
        AudioManager.skill(caster.global_position)
    caster.play_cast_feedback(color, 0.16, 2.0)
    VFXFactory.spawn_ring(get_tree().current_scene, caster.global_position + Vector3.UP * 0.1, color, 2.8, 0.28)
    var forward: Vector3 = caster.get_facing_direction()
    for enemy in TeamManager.get_enemies(caster.get_team()):
        if not CombatQueries.is_enemy(enemy, caster.get_team(), caster):
            continue
        var to_enemy: Vector3 = enemy.global_position - caster.global_position
        to_enemy.y = 0.0
        var dist: float = to_enemy.length()
        if dist > cast_range or dist <= 0.05:
            continue
        var dot: float = forward.dot(to_enemy.normalized())
        if dot < 0.18:
            continue
        var final_damage: float = DamageSystem.calculate_physical_damage(caster.get_attack_damage() + 120.0, CombatQueries.defense(enemy), damage)
        CombatQueries.apply_raw_damage(enemy, final_damage, caster)
        VFXFactory.spawn_burst(get_tree().current_scene, enemy.global_position + Vector3.UP * 0.8, color, 12, 0.22)
