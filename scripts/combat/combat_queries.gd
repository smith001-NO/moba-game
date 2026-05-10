extends RefCounted
class_name CombatQueries

static func health(node: Node) -> HealthComponent:
    if node == null:
        return null
    if node is HealthComponent:
        return node as HealthComponent
    if node.has_node("HealthComponent"):
        return node.get_node("HealthComponent") as HealthComponent
    return null

static func is_alive(node: Node) -> bool:
    if node == null or not is_instance_valid(node):
        return false
    if node.has_method("is_alive"):
        return bool(node.call("is_alive"))
    var health_component: HealthComponent = health(node)
    if health_component:
        return not health_component.is_dead and health_component.current_hp > 0.0
    return true

static func team(node: Node) -> int:
    if node == null:
        return GameManager.Team.NEUTRAL
    if node.has_method("get_team"):
        return int(node.call("get_team"))
    return GameManager.Team.NEUTRAL

static func defense(node: Node) -> float:
    if node != null and node.has_method("get_defense"):
        return float(node.call("get_defense"))
    return 0.0

static func magic_resistance(node: Node) -> float:
    if node != null and node.has_method("get_magic_resistance"):
        return float(node.call("get_magic_resistance"))
    return defense(node) * 0.65

static func is_enemy(candidate: Node3D, source_team: GameManager.Team, self_node: Node = null) -> bool:
    if candidate == null or not is_instance_valid(candidate) or candidate == self_node:
        return false
    var candidate_team: int = team(candidate)
    if candidate_team == GameManager.Team.NEUTRAL or candidate_team == source_team:
        return false
    return is_alive(candidate)

static func apply_raw_damage(target: Node3D, amount: float, attacker: Node3D = null) -> float:
    if target == null or not is_instance_valid(target):
        return 0.0
    var final_amount: float = maxf(amount, 0.0)
    # Prototype readability balance: red-side PvE/PvP pressure should not delete the player,
    # while player commands should feel responsive and visibly damage targets.
    if attacker and attacker is HeroBase and target is HeroBase:
        var attacker_hero: HeroBase = attacker as HeroBase
        var target_hero: HeroBase = target as HeroBase
        if target_hero.is_player_controlled and not attacker_hero.is_player_controlled:
            final_amount *= 0.62
        elif attacker_hero.is_player_controlled and not target_hero.is_player_controlled:
            final_amount *= 1.18
    elif attacker and attacker.has_method("get_team") and target is HeroBase:
        var target_hero_2: HeroBase = target as HeroBase
        if target_hero_2.is_player_controlled and int(attacker.call("get_team")) == GameManager.Team.RED:
            final_amount *= 0.70
    elif attacker is HeroBase and attacker.is_player_controlled:
        final_amount *= 1.12

    var health_component: HealthComponent = health(target)
    if attacker and target.has_method("set_meta"):
        target.set_meta("last_attacker", attacker)
    if health_component:
        return health_component.take_raw_damage(final_amount)
    if target.has_method("take_damage"):
        target.call("take_damage", final_amount, attacker)
        return final_amount
    return 0.0
