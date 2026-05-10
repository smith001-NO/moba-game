extends CharacterBody3D
class_name HeroBase

const MAX_LEVEL: int = 15
const PASSIVE_GOLD_PER_SECOND: int = 5
const PASSIVE_XP_PER_SECOND: float = 24.0
const FOUNTAIN_RADIUS: float = 9.5
const FOUNTAIN_HP_PERCENT_PER_SECOND: float = 0.10
const FOUNTAIN_MP_PERCENT_PER_SECOND: float = 0.16

const HeroVisualBuilder = preload("res://scripts/visuals/hero_visual_builder.gd")
const ITEM_CATALOG = preload("res://scripts/game/item_catalog.gd")
const HERO_STATS_PATHS: Dictionary = {
    "arc_knight": "res://resources/hero_stats_arc_knight.tres",
    "blade_dancer": "res://resources/hero_stats_blade_dancer.tres",
    "storm_mage": "res://resources/hero_stats_storm_mage.tres",
    "dawn_ranger": "res://resources/hero_stats_dawn_ranger.tres",
    "jade_guardian": "res://resources/hero_stats_jade_guardian.tres",
}

signal hp_changed(current_hp: float)
signal mp_changed(current_mp: float)
signal died()
signal respawned()
signal economy_changed(gold: int, xp: float, xp_to_next: float)
signal level_changed(level: int)

@export var stats: HeroStats
@export_enum("arc_knight", "blade_dancer", "storm_mage", "dawn_ranger", "jade_guardian") var hero_class: String = "arc_knight"
@export var team: GameManager.Team = GameManager.Team.BLUE
@export_node_path("Node3D") var skill_slots_path: NodePath = ^"SkillSlots"
@export var respawn_time: float = 5.0
@export var auto_acquire_range: float = 4.4
@export var leash_distance: float = 24.0
@export var auto_acquire_enabled: bool = false

var current_hp: float:
    set(value):
        if not stats:
            current_hp = value
            return
        current_hp = clampf(value, 0.0, stats.max_hp)
        hp_changed.emit(current_hp)
        if _health_component and not _syncing_health_component:
            _syncing_health_component = true
            _health_component.current_hp = current_hp
            _syncing_health_component = false
        if current_hp <= 0.0 and not is_dead:
            die()

var current_mp: float:
    set(value):
        if not stats:
            current_mp = value
            return
        current_mp = clampf(value, 0.0, stats.max_mp)
        mp_changed.emit(current_mp)

var target_position: Vector3 = Vector3.ZERO
var is_moving_to_target: bool = false
var current_attack_target: Node3D = null
var is_dead: bool = false
var spawn_position: Vector3 = Vector3.ZERO
var is_player_controlled: bool = false

var level: int = 1
var xp: float = 0.0
var xp_to_next: float = 100.0
var gold: int = 1000
var total_kills: int = 0
var total_minion_kills: int = 0
var kill_streak: int = 0
var death_count: int = 0
var last_killed_by: Node3D = null
var item_inventory: Array[Dictionary] = []

var _base_max_hp: float = 0.0
var _base_hp_regen: float = 0.0
var _base_max_mp: float = 0.0
var _base_mp_regen: float = 0.0
var _base_attack_damage: float = 0.0
var _base_defense: float = 0.0
var _base_attack_speed: float = 0.0
var _base_attack_range: float = 0.0
var _base_move_speed: float = 0.0
var _passive_income_timer: float = 0.0

var _gravity: float = 18.0
var _skill_slots: Node3D = null
var _regen_timer: float = 0.0
var _basic_attack_timer: float = 0.0
var _status_label: Label3D = null
var _health_component: HealthComponent = null
var _syncing_health_component: bool = false
var _facing_direction: Vector3 = Vector3.RIGHT
var _base_collision_layer: int = 2
var _base_collision_mask: int = 1
var _visual_root: Node3D = null
var _attack_target_was_commanded: bool = false

func _ready() -> void:
    _resolve_hero_class_and_stats()
    if not stats:
        push_error("HeroBase: stats is missing")
        return
    stats = stats.duplicate(true) as HeroStats
    stats.resource_local_to_scene = true
    set_meta("is_hero", true)
    spawn_position = global_position
    target_position = global_position
    _base_collision_layer = collision_layer
    _base_collision_mask = collision_mask
    xp_to_next = _xp_required_for_next(level)
    _capture_base_stats()
    _setup_health_component()
    current_hp = stats.max_hp
    current_mp = stats.max_mp
    _skill_slots = get_node_or_null(skill_slots_path) as Node3D
    _setup_skills()
    if name == "PlayerHero":
        set_player_controlled(true)
    _build_moba_visuals()
    _apply_team_visual()
    _create_status_label()
    economy_changed.emit(gold, xp, xp_to_next)
    if has_node("/root/EventBus"):
        EventBus.hero_economy_changed.emit(self)



func _process(delta: float) -> void:
    if is_dead:
        return
    _regen_tick(delta)
    _fountain_tick(delta)
    _progression_tick(delta)
    _basic_attack_timer = maxf(_basic_attack_timer - delta, 0.0)
    if _should_auto_acquire() and not current_attack_target and not is_moving_to_target:
        _auto_acquire_attack_target()
    _try_attack_current_target()
    _update_status_label()

func _physics_process(delta: float) -> void:
    if is_dead:
        return
    if is_moving_to_target:
        var dir: Vector3 = _direction_to(target_position)
        var distance: float = global_position.distance_to(target_position)
        if dir.length() > 0.05 and distance > 0.55:
            velocity.x = dir.x * stats.move_speed
            velocity.z = dir.z * stats.move_speed
            _apply_gravity(delta)
            move_and_slide()
            _look_toward(dir)
        else:
            stop_movement()
    else:
        velocity.x = move_toward(velocity.x, 0.0, stats.move_speed * delta * 10.0)
        velocity.z = move_toward(velocity.z, 0.0, stats.move_speed * delta * 10.0)
        _apply_gravity(delta)
        move_and_slide()

func set_player_controlled(value: bool) -> void:
    is_player_controlled = value
    if value:
        auto_acquire_enabled = false
        clear_attack_target()
        stop_movement()

func _should_auto_acquire() -> bool:
    return auto_acquire_enabled and not is_player_controlled and name != "PlayerHero"

func move_in_direction(direction: Vector3, delta: float) -> void:
    if is_dead:
        return
    is_moving_to_target = false
    var dir: Vector3 = direction.normalized()
    if dir.length() > 0.1:
        velocity.x = dir.x * stats.move_speed
        velocity.z = dir.z * stats.move_speed
        _look_toward(dir)
    else:
        velocity.x = 0.0
        velocity.z = 0.0
    _apply_gravity(delta)
    move_and_slide()

func move_to(target: Vector3) -> void:
    if is_dead:
        return
    target_position = target
    target_position.y = global_position.y
    is_moving_to_target = true

func stop_movement() -> void:
    is_moving_to_target = false
    target_position = global_position
    velocity.x = 0.0
    velocity.z = 0.0

func set_attack_target(target: Node3D) -> bool:
    if not _is_attack_target_valid(target):
        current_attack_target = null
        _attack_target_was_commanded = false
        return false
    current_attack_target = target
    _attack_target_was_commanded = true
    return basic_attack(target)

func clear_attack_target() -> void:
    current_attack_target = null
    _attack_target_was_commanded = false

func basic_attack(target: Node3D) -> bool:
    if is_dead or not _is_attack_target_valid(target):
        current_attack_target = null
        _attack_target_was_commanded = false
        return false
    current_attack_target = target
    var dist: float = global_position.distance_to(target.global_position)
    if dist > attack_range():
        if not _attack_target_was_commanded:
            current_attack_target = null
            return false
        if dist > leash_distance:
            current_attack_target = null
            _attack_target_was_commanded = false
            return false
        move_to(target.global_position)
        return false
    if _basic_attack_timer > 0.0:
        stop_movement()
        return false
    stop_movement()
    _look_toward(_direction_to(target.global_position))
    _apply_basic_attack(target)
    _basic_attack_timer = 1.0 / maxf(stats.attack_speed, 0.1)
    return true

func attack_range() -> float:
    return stats.attack_range + 0.45 if stats else 4.0

func find_nearest_enemy(range_limit: float) -> Node3D:
    var nearest: Node3D = null
    var min_dist: float = range_limit
    for enemy in TeamManager.get_enemies(team):
        if not _is_attack_target_valid(enemy):
            continue
        var dist: float = global_position.distance_to(enemy.global_position)
        if dist < min_dist:
            min_dist = dist
            nearest = enemy
    return nearest

func take_damage(amount: float, attacker: Node3D = null) -> void:
    if is_dead:
        return
    if attacker:
        set_meta("last_attacker", attacker)
    var actual_damage: float = DamageSystem.calculate_physical_damage(amount, get_defense(), amount)
    current_hp -= actual_damage

func heal(amount: float) -> void:
    if is_dead:
        return
    current_hp += amount

func consume_mana(amount: float) -> bool:
    if current_mp < amount:
        return false
    current_mp -= amount
    return true

func restore_mp(amount: float) -> void:
    current_mp += amount

func get_attack_damage() -> float:
    return stats.attack_damage if stats else 0.0

func get_defense() -> float:
    return stats.defense if stats else 0.0

func get_magic_resistance() -> float:
    return stats.defense * 0.65 if stats else 0.0

func get_team() -> GameManager.Team:
    return team

func is_alive() -> bool:
    return not is_dead and current_hp > 0.0

func get_facing_direction() -> Vector3:
    return _facing_direction

func die() -> void:
    if is_dead:
        return
    is_dead = true
    death_count += 1
    kill_streak = 0
    current_attack_target = null
    _attack_target_was_commanded = false
    _basic_attack_timer = 0.0
    stop_movement()
    died.emit()
    if has_node("/root/AudioManager"):
        AudioManager.death(global_position)
    if has_node("/root/TeamManager"):
        TeamManager.unregister_unit(self, team)
    collision_layer = 0
    collision_mask = 0
    visible = false
    set_physics_process(false)
    set_process(false)
    _award_death_score()
    _schedule_respawn()

func respawn() -> void:
    is_dead = false
    visible = true
    collision_layer = _base_collision_layer
    collision_mask = _base_collision_mask
    global_position = spawn_position
    velocity = Vector3.ZERO
    current_attack_target = null
    _attack_target_was_commanded = false
    _basic_attack_timer = 0.0
    _syncing_health_component = true
    if _health_component:
        _health_component.reset()
    _syncing_health_component = false
    current_hp = stats.max_hp
    current_mp = stats.max_mp
    set_physics_process(true)
    set_process(true)
    if has_node("/root/TeamManager"):
        TeamManager.register_unit(self, team)
    respawned.emit()

func _schedule_respawn() -> void:
    await get_tree().create_timer(respawn_time).timeout
    if is_inside_tree():
        respawn()

func _award_death_score() -> void:
    var killer: Node3D = get_meta("last_attacker", null) as Node3D
    if not killer:
        return
    var killer_team: int = CombatQueries.team(killer)
    GameManager.add_score(killer_team, 3)
    if killer is HeroBase and killer != self and killer_team != team:
        var hero_killer := killer as HeroBase
        var revenge: bool = hero_killer.last_killed_by == self
        hero_killer.total_kills += 1
        hero_killer.kill_streak += 1
        hero_killer.last_killed_by = null
        last_killed_by = hero_killer
        hero_killer.grant_rewards(650.0, 520, "hero")
        if has_node("/root/EventBus"):
            EventBus.hero_killed.emit(self, hero_killer, hero_killer.kill_streak, revenge)
        if has_node("/root/AudioManager") and hero_killer.is_player_controlled:
            if AudioManager.has_method("kill_event"):
                AudioManager.kill_event(hero_killer.kill_streak, revenge)
            else:
                AudioManager.kill()


func _resolve_hero_class_and_stats() -> void:
    if name == "PlayerHero" and has_node("/root/GameManager"):
        if GameManager.has_method("get_selected_hero_class") and String(GameManager.get_selected_hero_class()) != "":
            hero_class = String(GameManager.get_selected_hero_class())
        elif String(GameManager.selected_hero_class) != "":
            hero_class = String(GameManager.selected_hero_class)
    elif (team == GameManager.Team.RED or name.begins_with("Enemy")) and hero_class == "arc_knight":
        hero_class = "storm_mage"
    elif name.begins_with("AIHero") and hero_class == "arc_knight":
        hero_class = "jade_guardian"
    var stat_res: HeroStats = _load_stats_for_class(hero_class)
    if stat_res:
        stats = stat_res

func _load_stats_for_class(class_id: String) -> HeroStats:
    var path: String = String(HERO_STATS_PATHS.get(class_id, HERO_STATS_PATHS.get("arc_knight")))
    if path != "" and ResourceLoader.exists(path):
        return load(path) as HeroStats
    return stats

func _stats_path_for_class(class_id: String) -> String:
    return String(HERO_STATS_PATHS.get(class_id, HERO_STATS_PATHS.get("arc_knight")))

func _capture_base_stats() -> void:
    _base_max_hp = stats.max_hp
    _base_hp_regen = stats.hp_regen
    _base_max_mp = stats.max_mp
    _base_mp_regen = stats.mp_regen
    _base_attack_damage = stats.attack_damage
    _base_defense = stats.defense
    _base_attack_speed = stats.attack_speed
    _base_attack_range = stats.attack_range
    _base_move_speed = stats.move_speed

func grant_rewards(xp_amount: float, gold_amount: int, source: String = "") -> void:
    add_experience(xp_amount)
    add_gold(gold_amount)
    if has_node("/root/EventBus"):
        EventBus.hero_economy_changed.emit(self)
    if source == "minion":
        total_minion_kills += 1

func add_experience(amount: float) -> void:
    if amount <= 0.0 or level >= MAX_LEVEL:
        return
    xp += amount
    var leveled: bool = false
    while level < MAX_LEVEL and xp >= xp_to_next:
        xp -= xp_to_next
        _level_up()
        leveled = true
    if leveled and has_node("/root/AudioManager") and is_player_controlled:
        AudioManager.level_up()
    economy_changed.emit(gold, xp, xp_to_next)
    if has_node("/root/EventBus"):
        EventBus.hero_economy_changed.emit(self)

func add_gold(amount: int) -> void:
    if amount == 0:
        return
    gold = max(0, gold + amount)
    economy_changed.emit(gold, xp, xp_to_next)
    if has_node("/root/EventBus"):
        EventBus.hero_economy_changed.emit(self)

func _level_up() -> void:
    level += 1
    xp_to_next = _xp_required_for_next(level)
    _recompute_stats()
    current_hp = minf(stats.max_hp, current_hp + 520.0 + float(level) * 35.0)
    current_mp = minf(stats.max_mp, current_mp + 145.0)
    if _health_component:
        _health_component.max_hp = stats.max_hp
        _health_component.current_hp = current_hp
    play_cast_feedback(Color(1.0, 0.86, 0.28, 1.0), 0.24, 2.2)
    level_changed.emit(level)
    if has_node("/root/EventBus"):
        EventBus.hero_level_changed.emit(self, level)
        EventBus.hero_economy_changed.emit(self)

func buy_item(item_id: String) -> bool:
    var item: Dictionary = ITEM_CATALOG.get_item(item_id)
    if item.is_empty():
        return false
    if item_inventory.size() >= 6:
        return false
    var cost: int = int(item.get("cost", 0))
    if gold < cost:
        return false
    gold -= cost
    item_inventory.append(item.duplicate(true))
    _recompute_stats()
    current_hp = minf(current_hp + float(item.get("hp", 0.0)) * 0.55, stats.max_hp)
    current_mp = minf(current_mp + float(item.get("mp", 0.0)) * 0.55, stats.max_mp)
    economy_changed.emit(gold, xp, xp_to_next)
    if has_node("/root/EventBus"):
        EventBus.hero_economy_changed.emit(self)
    if has_node("/root/AudioManager"):
        AudioManager.purchase()
    return true

func buy_shop_item(index: int) -> bool:
    var items: Array[Dictionary] = ITEM_CATALOG.get_items()
    if index < 0 or index >= items.size():
        return false
    return buy_item(String(items[index].get("id", "")))

func get_shop_items() -> Array[Dictionary]:
    return ITEM_CATALOG.get_items()

func try_auto_buy_item() -> bool:
    return auto_buy_best_item()

func auto_buy_best_item() -> bool:
    if item_inventory.size() >= 6:
        return false
    var chosen: Dictionary = {}
    for item in ITEM_CATALOG.get_items():
        var cost: int = int(item.get("cost", 0))
        if cost <= gold and (chosen.is_empty() or cost > int(chosen.get("cost", 0))):
            chosen = item
    if chosen.is_empty():
        return false
    return buy_item(String(chosen.get("id", "")))

func _recompute_stats() -> void:
    var level_index: float = float(level - 1)
    var bonus_hp: float = 0.0
    var bonus_mp: float = 0.0
    var bonus_attack: float = 0.0
    var bonus_defense: float = 0.0
    var bonus_attack_speed: float = 0.0
    var bonus_range: float = 0.0
    var bonus_move: float = 0.0
    var bonus_hp_regen: float = 0.0
    var bonus_mp_regen: float = 0.0
    for item in item_inventory:
        bonus_hp += float(item.get("hp", 0.0))
        bonus_mp += float(item.get("mp", 0.0))
        bonus_attack += float(item.get("attack", 0.0))
        bonus_defense += float(item.get("defense", 0.0))
        bonus_attack_speed += float(item.get("attack_speed", 0.0))
        bonus_range += float(item.get("range", 0.0))
        bonus_move += float(item.get("move_speed", 0.0))
        bonus_hp_regen += float(item.get("hp_regen", 0.0))
        bonus_mp_regen += float(item.get("mp_regen", 0.0))
    stats.max_hp = _base_max_hp + level_index * 650.0 + bonus_hp
    stats.max_mp = _base_max_mp + level_index * 135.0 + bonus_mp
    stats.attack_damage = _base_attack_damage + level_index * 32.0 + bonus_attack
    stats.defense = _base_defense + level_index * 10.0 + bonus_defense
    stats.attack_speed = minf(_base_attack_speed + level_index * 0.035 + bonus_attack_speed, 2.8)
    stats.attack_range = _base_attack_range + bonus_range
    stats.move_speed = _base_move_speed + minf(level_index * 0.045 + bonus_move, 2.0)
    stats.hp_regen = _base_hp_regen + level_index * 3.8 + bonus_hp_regen
    stats.mp_regen = _base_mp_regen + level_index * 2.5 + bonus_mp_regen
    if _health_component:
        _health_component.max_hp = stats.max_hp

func get_inventory_names() -> String:
    if item_inventory.is_empty():
        return "None"
    var names: Array[String] = []
    for item in item_inventory:
        names.append(String(item.get("name", "Item")))
    return ", ".join(names)

func get_total_item_cost() -> int:
    var total: int = 0
    for item in item_inventory:
        total += int(item.get("cost", 0))
    return total

func get_net_worth() -> int:
    return gold + get_total_item_cost()

func get_display_name() -> String:
    var hero_title: String = stats.hero_name if stats else name
    if name == "PlayerHero":
        return "Player %s" % hero_title
    if name.begins_with("Enemy"):
        return "Red %s" % hero_title
    if name.begins_with("AIHero"):
        return "Blue Ally %s" % hero_title
    return name

func get_economy_line() -> String:
    var team_text: String = "蓝" if team == GameManager.Team.BLUE else "红"
    return "%s %s  Lv.%d  经济:%d  金币:%d  装备:%s" % [team_text, get_display_name(), level, get_net_worth(), gold, get_inventory_names()]

func _xp_required_for_next(current_level: int) -> float:
    # 非线性经验表：低等级升级很快，高等级逐步变慢，满级 15。
    var table: Array[float] = [70.0, 110.0, 170.0, 260.0, 400.0, 620.0, 900.0, 1250.0, 1650.0, 2150.0, 2800.0, 3600.0, 4550.0, 5700.0]
    if current_level < 1:
        return table[0]
    if current_level >= MAX_LEVEL:
        return 0.0
    return table[current_level - 1]

func _progression_tick(delta: float) -> void:
    if GameManager.current_state != GameManager.GameState.PLAYING:
        return
    _passive_income_timer += delta
    while _passive_income_timer >= 1.0:
        _passive_income_timer -= 1.0
        add_gold(PASSIVE_GOLD_PER_SECOND)
        add_experience(PASSIVE_XP_PER_SECOND)

func _apply_basic_attack(target: Node3D) -> void:
    if not target or not is_instance_valid(target):
        return
    var projectile_scene: PackedScene = preload("res://scenes/combat/projectile.tscn")
    var projectile: Projectile = projectile_scene.instantiate() as Projectile
    projectile.owner_team = get_team()
    projectile.attack_stat = get_attack_damage()
    projectile.damage_type = DamageSystem.DamageType.PHYSICAL
    projectile.damage = maxf(stats.attack_damage * 0.86, 1.0)
    projectile.max_distance = attack_range() + 8.0
    projectile.speed = 52.0
    projectile.pierce_count = 0
    projectile.trail_color = Color(0.34, 0.82, 1.0, 1.0) if get_team() == GameManager.Team.BLUE else Color(1.0, 0.38, 0.22, 1.0)
    var aim: Vector3 = target.global_position + Vector3.UP * 1.0
    var origin: Vector3 = global_position + Vector3.UP * 1.22 + _direction_to(target.global_position) * 0.55
    get_tree().current_scene.add_child(projectile)
    projectile.initialize_target(origin, target, self)
    VFXFactory.spawn_projectile_trail(get_tree().current_scene, origin, projectile.trail_color, 0.18)
    if has_node("/root/AudioManager"):
        AudioManager.skill(global_position)

func _spawn_hit_spark(pos: Vector3) -> void:
    if has_node("/root/AudioManager"):
        AudioManager.hit(pos)
    if get_tree().current_scene:
        VFXFactory.spawn_burst(get_tree().current_scene, pos + Vector3.UP * 0.75, Color(1.0, 0.82, 0.32, 1.0), 8, 0.22)
        var spark: OmniLight3D = OmniLight3D.new()
        spark.name = "HitSpark"
        spark.light_color = Color(1.0, 0.82, 0.32, 1.0)
        spark.light_energy = 1.4
        spark.omni_range = 2.3
        spark.global_position = pos + Vector3.UP
        get_tree().current_scene.add_child(spark)
        var tween: Tween = spark.create_tween()
        tween.tween_property(spark, "light_energy", 0.0, 0.18)
        tween.tween_callback(spark.queue_free)

func _direction_to(target: Vector3) -> Vector3:
    var dir: Vector3 = target - global_position
    dir.y = 0.0
    return dir.normalized()

func _look_toward(dir: Vector3) -> void:
    if dir.length() <= 0.01:
        return
    _facing_direction = dir.normalized()
    look_at(global_position + _facing_direction, Vector3.UP, true)

func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= _gravity * delta
    else:
        velocity.y = -0.1

func _regen_tick(delta: float) -> void:
    _regen_timer += delta
    if _regen_timer >= 1.0:
        _regen_timer -= 1.0
        current_hp = minf(current_hp + stats.hp_regen, stats.max_hp)
        current_mp = minf(current_mp + stats.mp_regen, stats.max_mp)

func _fountain_tick(delta: float) -> void:
    if not stats or GameManager.current_state != GameManager.GameState.PLAYING:
        return
    var map := get_tree().get_first_node_in_group("game_map") as GameMap
    if not map:
        return
    var fountain_pos: Vector3 = map.get_blue_spawn_position() if team == GameManager.Team.BLUE else map.get_red_spawn_position()
    var flat_self: Vector3 = Vector3(global_position.x, 0.0, global_position.z)
    var flat_fountain: Vector3 = Vector3(fountain_pos.x, 0.0, fountain_pos.z)
    if flat_self.distance_to(flat_fountain) <= FOUNTAIN_RADIUS:
        current_hp = minf(current_hp + stats.max_hp * FOUNTAIN_HP_PERCENT_PER_SECOND * delta, stats.max_hp)
        current_mp = minf(current_mp + stats.max_mp * FOUNTAIN_MP_PERCENT_PER_SECOND * delta, stats.max_mp)

func _auto_acquire_attack_target() -> void:
    var passive_range: float = maxf(0.1, minf(auto_acquire_range, attack_range() - 0.05))
    var nearest: Node3D = find_nearest_enemy(passive_range)
    if nearest:
        current_attack_target = nearest
        _attack_target_was_commanded = false

func _try_attack_current_target() -> void:
    if not current_attack_target:
        return
    if not _is_attack_target_valid(current_attack_target):
        current_attack_target = null
        _attack_target_was_commanded = false
        return
    var dist: float = global_position.distance_to(current_attack_target.global_position)
    if dist > leash_distance:
        current_attack_target = null
        _attack_target_was_commanded = false
        return
    if not _attack_target_was_commanded and dist > attack_range():
        current_attack_target = null
        return
    basic_attack(current_attack_target)

func _is_attack_target_valid(target: Node3D) -> bool:
    return CombatQueries.is_enemy(target, team, self)

func _setup_health_component() -> void:
    _health_component = get_node_or_null("HealthComponent") as HealthComponent
    if not _health_component:
        return
    _health_component.max_hp = stats.max_hp
    _health_component.current_hp = stats.max_hp
    if not _health_component.health_changed.is_connected(_on_health_component_changed):
        _health_component.health_changed.connect(_on_health_component_changed)
    if not _health_component.died.is_connected(_on_health_component_died):
        _health_component.died.connect(_on_health_component_died)

func _on_health_component_changed(current: float, _max_hp: float) -> void:
    if _syncing_health_component:
        return
    _syncing_health_component = true
    current_hp = current
    _syncing_health_component = false

func _on_health_component_died() -> void:
    die()

func _setup_skills() -> void:
    if not _skill_slots:
        return
    for child in _skill_slots.get_children():
        if child is SkillBase:
            (child as SkillBase).set_caster(self)

func _hero_theme_key() -> String:
    if team == GameManager.Team.RED or name.begins_with("Enemy"):
        return "crimson"
    return "azure"

func _build_moba_visuals() -> void:
    for child in get_children():
        if child is MeshInstance3D:
            child.queue_free()
        elif child is Node3D and child.name == "HeroVisuals":
            child.queue_free()
    _visual_root = HeroVisualBuilder.build(self, _hero_theme_key())

func _apply_team_visual() -> void:
    pass

func flash_visual(color: Color, duration: float = 0.18) -> void:
    if not _visual_root:
        return
    var light := OmniLight3D.new()
    light.name = "HeroCastFlash"
    light.light_color = color
    light.light_energy = 2.0
    light.omni_range = 4.0
    light.position = Vector3(0.0, 1.0, 0.0)
    add_child(light)
    var start_scale: Vector3 = _visual_root.scale
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(_visual_root, "scale", start_scale * 1.045, duration * 0.5)
    tween.tween_property(light, "light_energy", 0.0, duration)
    tween.set_parallel(false)
    tween.tween_property(_visual_root, "scale", start_scale, duration * 0.5)
    tween.tween_callback(light.queue_free)

func spawn_cast_ring(color: Color, radius: float = 1.4, duration: float = 0.32) -> void:
    var ring := MeshInstance3D.new()
    ring.name = "CastRing"
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = 0.035
    ring.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = 1.2
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    ring.set_surface_override_material(0, mat)
    get_tree().current_scene.add_child(ring)
    ring.global_position = global_position + Vector3(0, 0.08, 0)
    var tween := ring.create_tween()
    tween.set_parallel(true)
    tween.tween_property(ring, "scale", Vector3(1.6, 1.0, 1.6), duration)
    tween.tween_property(mat, "albedo_color", Color(color.r, color.g, color.b, 0.0), duration)
    tween.set_parallel(false)
    tween.tween_callback(ring.queue_free)

func play_cast_feedback(color: Color = Color(0.5, 0.9, 1.0, 1.0), duration: float = 0.18, radius: float = 1.7) -> void:
    if is_dead:
        return
    flash_visual(color, duration)
    spawn_cast_ring(color, radius, maxf(duration * 1.65, 0.28))

func spawn_skill_ring(color: Color, radius: float = 2.0, duration: float = 0.45) -> void:
    spawn_cast_ring(color, radius, duration)

func spawn_dash_afterimage(color: Color, direction: Vector3, distance: float) -> void:
    if get_tree().current_scene:
        VFXFactory.spawn_afterimage(get_tree().current_scene, global_position, direction, color, 0.26)

func _create_status_label() -> void:
    if _status_label:
        return
    _status_label = Label3D.new()
    _status_label.name = "StatusLabel"
    _status_label.position = Vector3(0.0, 3.15, 0.0)
    _status_label.font_size = 28
    add_child(_status_label)
    _update_status_label()

func _update_status_label() -> void:
    if not _status_label or not stats:
        return
    var team_text: String = "BLUE"
    if team != GameManager.Team.BLUE:
        team_text = "RED"
    _status_label.text = "%s Lv.%d\nHP %.0f/%.0f" % [team_text, level, current_hp, stats.max_hp]
