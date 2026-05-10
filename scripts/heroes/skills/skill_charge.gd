extends SkillBase
class_name SkillCharge

@export var dash_steps: int = 2
@export var step_distance: float = 4.1
@export var step_duration: float = 0.12

func _ready() -> void:
    skill_name = "Phantom Steps"
    description = "E: Two-stage dash with landing damage."
    cooldown = 3.0
    mana_cost = 18.0
    cast_range = 8.2
    damage = 210.0

func _apply_skill(target: Node3D) -> void:
    var caster: HeroBase = _caster as HeroBase
    if not caster:
        return
    var color: Color = Color(0.35, 0.82, 1.0, 1.0) if caster.get_team() == GameManager.Team.BLUE else Color(1.0, 0.32, 0.15, 1.0)
    var direction: Vector3 = caster.get_facing_direction()
    if target and is_instance_valid(target):
        direction = target.global_position - caster.global_position
        direction.y = 0.0
    if direction.length() <= 0.01:
        direction = Vector3.RIGHT
    direction = direction.normalized()
    if has_node("/root/AudioManager"):
        AudioManager.skill(caster.global_position)
    caster.play_cast_feedback(color, 0.12)
    caster.stop_movement()
    for i in range(dash_steps):
        VFXFactory.spawn_afterimage(get_tree().current_scene, caster.global_position, direction, color, 0.26)
        var end_pos: Vector3 = caster.global_position + direction * step_distance
        end_pos.y = caster.global_position.y
        var tween: Tween = create_tween()
        tween.tween_property(caster, "global_position", end_pos, step_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
        await tween.finished
        VFXFactory.spawn_ring(get_tree().current_scene, caster.global_position + Vector3.UP * 0.08, color, 1.35 + float(i) * 0.35, 0.24)
        _deal_aoe_damage(caster, caster.global_position, 2.25 + float(i) * 0.25, damage)

func _deal_aoe_damage(caster: HeroBase, center: Vector3, radius: float, dmg: float) -> void:
    for enemy in TeamManager.get_enemies(caster.get_team()):
        if not CombatQueries.is_enemy(enemy, caster.get_team(), caster):
            continue
        if center.distance_to(enemy.global_position) > radius:
            continue
        var final_damage: float = DamageSystem.calculate_physical_damage(caster.get_attack_damage(), CombatQueries.defense(enemy), dmg)
        CombatQueries.apply_raw_damage(enemy, final_damage, caster)
