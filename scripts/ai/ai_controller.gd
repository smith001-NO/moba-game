extends Node
class_name AIController

@export var hero: HeroBase
@export var team: GameManager.Team = GameManager.Team.RED
@export var retreat_hp_ratio: float = 0.28
@export var engagement_range: float = 11.0

var current_target: Node3D = null
var state_machine: AIStateMachine = null
var _skill_logic_cooldown: float = 0.0
var _shop_timer: float = 0.0

func _ready() -> void:
    if not hero:
        hero = get_parent() as HeroBase
    if not hero:
        push_error("AIController: HeroBase not found")
        set_process(false)
        return
    team = hero.team
    hero.team = team
    hero.auto_acquire_enabled = true
    if has_node("/root/TeamManager"):
        TeamManager.register_unit(hero, team)
    state_machine = get_node_or_null("AIStateMachine") as AIStateMachine
    if state_machine:
        state_machine.initialize(self, hero)

func _process(delta: float) -> void:
    if not hero or hero.is_dead or GameManager.current_state != GameManager.GameState.PLAYING:
        return
    _skill_logic_cooldown = maxf(_skill_logic_cooldown - delta, 0.0)
    _shop_timer += delta
    if _shop_timer >= 12.0:
        _shop_timer = 0.0
        if hero and hero.has_method("try_auto_buy_item"):
            hero.try_auto_buy_item()
    if state_machine:
        state_machine.update(delta)

func move_to(pos: Vector3) -> void:
    if hero:
        hero.move_to(pos)

func should_retreat() -> bool:
    if not hero or not hero.stats:
        return false
    return hero.current_hp <= hero.stats.max_hp * retreat_hp_ratio

func find_nearest_enemy_hero() -> Node3D:
    var nearest: Node3D = null
    var min_dist: float = engagement_range
    for enemy in TeamManager.get_enemies(team):
        if not _is_valid_enemy(enemy):
            continue
        if enemy.has_meta("is_minion") or enemy.has_meta("is_tower") or enemy.has_meta("is_nexus"):
            continue
        var dist: float = hero.global_position.distance_to(enemy.global_position)
        if dist < min_dist:
            min_dist = dist
            nearest = enemy
    return nearest

func find_nearest_minion() -> Node3D:
    var nearest: Node3D = null
    var min_dist: float = 12.5
    for enemy in TeamManager.get_enemies(team):
        if not _is_valid_enemy(enemy) or not enemy.has_meta("is_minion"):
            continue
        var dist: float = hero.global_position.distance_to(enemy.global_position)
        if dist < min_dist:
            min_dist = dist
            nearest = enemy
    return nearest

func find_nearest_tower() -> Node3D:
    var nearest: Node3D = null
    var min_dist: float = 18.0
    for enemy in TeamManager.get_enemies(team):
        if not _is_valid_enemy(enemy):
            continue
        if not enemy.has_meta("is_tower") and not enemy.has_meta("is_nexus"):
            continue
        var dist: float = hero.global_position.distance_to(enemy.global_position)
        if dist < min_dist:
            min_dist = dist
            nearest = enemy
    return nearest

func try_use_combat_skills(target: Node3D) -> void:
    if not hero or _skill_logic_cooldown > 0.0 or not hero.has_node("SkillSlots"):
        return
    var slots := hero.get_node("SkillSlots") as Node3D
    if not slots or slots.get_child_count() == 0:
        return
    var dist: float = INF
    if target and is_instance_valid(target):
        dist = hero.global_position.distance_to(target.global_position)
    if hero.current_hp <= hero.stats.max_hp * 0.55:
        if _cast_slot(slots, 2, null):
            _skill_logic_cooldown = 1.15
            return
    if target and dist <= 4.0:
        if _cast_slot(slots, 3, target):
            _skill_logic_cooldown = 1.05
            return
    if target and dist > hero.attack_range() + 0.4 and dist <= 8.5:
        if _cast_slot(slots, 1, target):
            _skill_logic_cooldown = 1.05
            return
    if target and dist <= 16.0:
        if _cast_slot(slots, 4, target):
            _skill_logic_cooldown = 1.35
            return
    if target and dist <= 22.0:
        if _cast_slot(slots, 0, target):
            _skill_logic_cooldown = 1.05
            return

func _cast_slot(slots: Node3D, slot_index: int, target: Node3D) -> bool:
    if slot_index < 0 or slot_index >= slots.get_child_count():
        return false
    var skill := slots.get_child(slot_index) as SkillBase
    if not skill:
        return false
    skill.set_caster(hero)
    return skill.cast(target)

func _is_valid_enemy(enemy: Node3D) -> bool:
    return CombatQueries.is_enemy(enemy, team, hero)
