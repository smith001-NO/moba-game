extends Node
class_name AIStateMachine

enum State { IDLE, PUSH_LANE, ATTACK_MINION, ATTACK_HERO, ATTACK_TOWER, RETREAT }

var current_state: State = State.IDLE
var controller: AIController
var hero: HeroBase
var state_time: float = 0.0
var decision_interval: float = 0.22
var decision_timer: float = 0.0

func initialize(ai_controller: AIController, controlled_hero: HeroBase) -> void:
    controller = ai_controller
    hero = controlled_hero

func update(delta: float) -> void:
    if not controller or not hero:
        return
    state_time += delta
    decision_timer += delta
    if decision_timer >= decision_interval:
        decision_timer = 0.0
        _evaluate_state_transition()
    match current_state:
        State.IDLE:
            _state_push_lane()
        State.PUSH_LANE:
            _state_push_lane()
        State.ATTACK_MINION, State.ATTACK_HERO, State.ATTACK_TOWER:
            _attack_target(controller.current_target)
        State.RETREAT:
            _state_retreat()

func _evaluate_state_transition() -> void:
    if controller.should_retreat():
        _change_state(State.RETREAT)
        return

    var enemy_hero: Node3D = controller.find_nearest_enemy_hero()
    if enemy_hero and hero.global_position.distance_to(enemy_hero.global_position) < 8.5:
        controller.current_target = enemy_hero
        _change_state(State.ATTACK_HERO)
        return

    var enemy_minion: Node3D = controller.find_nearest_minion()
    if enemy_minion:
        controller.current_target = enemy_minion
        _change_state(State.ATTACK_MINION)
        return

    var enemy_tower: Node3D = controller.find_nearest_tower()
    if enemy_tower:
        controller.current_target = enemy_tower
        _change_state(State.ATTACK_TOWER)
        return

    if enemy_hero:
        controller.current_target = enemy_hero
        _change_state(State.ATTACK_HERO)
        return

    controller.current_target = null
    _change_state(State.PUSH_LANE)

func _change_state(new_state: State) -> void:
    if current_state == new_state:
        return
    current_state = new_state
    state_time = 0.0
    if new_state == State.RETREAT:
        controller.current_target = null
        hero.clear_attack_target()

func _state_push_lane() -> void:
    var game_map := get_tree().get_first_node_in_group("game_map") as GameMap
    if not game_map:
        return
    var target_pos: Vector3 = game_map.get_red_spawn_position() if controller.team == GameManager.Team.BLUE else game_map.get_blue_spawn_position()
    controller.move_to(target_pos)

func _state_retreat() -> void:
    var game_map := get_tree().get_first_node_in_group("game_map") as GameMap
    if not game_map:
        return
    var safe_pos: Vector3 = game_map.get_blue_spawn_position() if controller.team == GameManager.Team.BLUE else game_map.get_red_spawn_position()
    controller.move_to(safe_pos)
    if hero.global_position.distance_to(safe_pos) < 5.0:
        hero.heal(35.0)

func _attack_target(target: Node3D) -> void:
    if not _is_target_valid(target):
        controller.current_target = null
        _change_state(State.PUSH_LANE)
        return
    controller.try_use_combat_skills(target)
    var dist: float = hero.global_position.distance_to(target.global_position)
    if dist > hero.attack_range() + 0.5:
        controller.move_to(target.global_position)
    else:
        hero.set_attack_target(target)

func _is_target_valid(target: Node3D) -> bool:
    if not target or not is_instance_valid(target):
        return false
    if target.has_method("is_alive") and not target.is_alive():
        return false
    return true
