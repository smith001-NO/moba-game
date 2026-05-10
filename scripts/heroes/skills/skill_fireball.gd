extends SkillBase
class_name SkillFireball

func _ready() -> void:
    skill_name = "Arc Volley"
    description = "Q: Fire three piercing crystal bolts in a narrow fan."
    cooldown = 1.45
    mana_cost = 16.0
    cast_range = 20.0
    damage = 260.0

func _apply_skill(target: Node3D) -> void:
    var caster: HeroBase = _caster as HeroBase
    if not caster:
        return
    var cast_color: Color = Color(0.25, 0.72, 1.0, 1.0) if caster.get_team() == GameManager.Team.BLUE else Color(1.0, 0.26, 0.12, 1.0)
    if has_node("/root/AudioManager"):
        AudioManager.skill(caster.global_position)
    caster.play_cast_feedback(cast_color, 0.18)
    VFXFactory.spawn_burst(get_tree().current_scene, caster.global_position + Vector3.UP * 1.2, cast_color, 12, 0.28)

    var origin: Vector3 = caster.global_position + Vector3(0.0, 1.25, 0.0)
    var base_direction: Vector3 = caster.get_facing_direction()
    if target and is_instance_valid(target):
        base_direction = (target.global_position + Vector3.UP - origin).normalized()
    var angles: Array[float] = [-8.0, 0.0, 8.0]
    for a in angles:
        _spawn_projectile(caster, origin, _rotate_y(base_direction, deg_to_rad(a)), cast_color)

func _spawn_projectile(caster: HeroBase, origin: Vector3, direction: Vector3, cast_color: Color) -> void:
    var projectile_scene: PackedScene = preload("res://scenes/combat/projectile.tscn")
    var projectile: Projectile = projectile_scene.instantiate() as Projectile
    projectile.owner_team = caster.get_team()
    projectile.attack_stat = caster.get_attack_damage() + 130.0
    projectile.damage_type = DamageSystem.DamageType.MAGIC
    projectile.damage = damage
    projectile.max_distance = cast_range + 4.0
    projectile.speed = 37.0
    projectile.pierce_count = 1
    projectile.trail_color = cast_color
    get_tree().current_scene.add_child(projectile)
    projectile.initialize(origin, direction, caster)

func _rotate_y(dir: Vector3, angle: float) -> Vector3:
    var basis := Basis(Vector3.UP, angle)
    return (basis * dir).normalized()
