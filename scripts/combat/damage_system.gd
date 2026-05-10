extends Node
class_name DamageSystem

enum DamageType { PHYSICAL, MAGIC, TRUE }

static func calculate_physical_damage(attacker_atk: float, defender_def: float, base_damage: float) -> float:
    var defense = maxf(defender_def, 0.0)
    var damage_reduction = defense / (defense + 100.0)
    var scaling = 0.75 + maxf(attacker_atk, 0.0) / 200.0
    return maxf(base_damage * scaling * (1.0 - damage_reduction), 1.0)

static func calculate_magic_damage(attacker_ap: float, defender_mr: float, base_damage: float) -> float:
    var defense = maxf(defender_mr, 0.0)
    var damage_reduction = defense / (defense + 100.0)
    var scaling = 0.8 + maxf(attacker_ap, 0.0) / 220.0
    return maxf(base_damage * scaling * (1.0 - damage_reduction), 1.0)

static func calculate_true_damage(base_damage: float) -> float:
    return maxf(base_damage, 1.0)

static func calculate_damage(attack_stat: float, defense_stat: float, base_damage: float, damage_type: DamageType) -> float:
    match damage_type:
        DamageType.PHYSICAL:
            return calculate_physical_damage(attack_stat, defense_stat, base_damage)
        DamageType.MAGIC:
            return calculate_magic_damage(attack_stat, defense_stat, base_damage)
        DamageType.TRUE:
            return calculate_true_damage(base_damage)
        _:
            return maxf(base_damage, 1.0)
