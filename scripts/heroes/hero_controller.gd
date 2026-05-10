extends Node
class_name HeroController

@export var hero: HeroBase
@export var camera: CameraController

const SKILL_SLOT_KEYS: Dictionary = {
    KEY_Q: 0,
    KEY_E: 1,
    KEY_R: 2,
    KEY_1: 3,
    KEY_2: 4,
}

func _ready() -> void:
    if not hero:
        hero = get_parent() as HeroBase
    if not hero:
        push_error("HeroController: HeroBase not found")
        set_process_input(false)
        set_physics_process(false)
        return
    if hero.name != "PlayerHero":
        set_process_input(false)
        set_physics_process(false)
        return
    hero.team = GameManager.Team.BLUE
    hero.set_player_controlled(true)
    GameManager.player_team = GameManager.Team.BLUE
    hero.add_to_group("player_hero")
    if has_node("/root/TeamManager"):
        TeamManager.register_unit(hero, GameManager.Team.BLUE)
    if not camera:
        camera = hero.get_node_or_null("Camera3D") as CameraController
    if camera:
        camera.activate_for_player(hero)

func _input(event: InputEvent) -> void:
    if not hero or hero.is_dead or GameManager.current_state != GameManager.GameState.PLAYING:
        return
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT or (event.button_index == MOUSE_BUTTON_RIGHT and not Input.is_key_pressed(KEY_ALT)):
            _handle_pointer_command(event)
    if event is InputEventKey and event.pressed and not event.echo:
        if SKILL_SLOT_KEYS.has(event.keycode):
            _cast_skill_in_slot(SKILL_SLOT_KEYS[event.keycode])
        elif event.keycode == KEY_SPACE and camera:
            camera.center_on_target(true)
        elif event.keycode == KEY_F:
            _focus_nearest_enemy()
        elif event.keycode == KEY_C and camera:
            camera.reset_view()
        elif event.keycode == KEY_ESCAPE:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    if not hero or hero.is_dead or GameManager.current_state != GameManager.GameState.PLAYING:
        return

    # Hybrid PC MOBA controls:
    # - Mouse click remains the main move / attack command.
    # - WASD is restored as direct hero movement so the player is never stuck only moving the camera.
    # - Arrow keys and screen edges are reserved for camera panning.
    var input_dir_2d: Vector2 = Vector2.ZERO
    if Input.is_key_pressed(KEY_A):
        input_dir_2d.x -= 1.0
    if Input.is_key_pressed(KEY_D):
        input_dir_2d.x += 1.0
    if Input.is_key_pressed(KEY_W):
        input_dir_2d.y += 1.0
    if Input.is_key_pressed(KEY_S):
        input_dir_2d.y -= 1.0

    if input_dir_2d.length() > 0.1:
        var world_dir: Vector3 = _screen_relative_move_direction(input_dir_2d.normalized())
        hero.clear_attack_target()
        hero.stop_movement()
        hero.move_in_direction(world_dir, delta)

func _screen_relative_move_direction(input_vec: Vector2) -> Vector3:
    if camera:
        var forward: Vector3 = camera.get_flat_forward()
        var right: Vector3 = camera.get_flat_right()
        var dir: Vector3 = right * input_vec.x + forward * input_vec.y
        dir.y = 0.0
        if dir.length() > 0.01:
            return dir.normalized()
    return Vector3(input_vec.y, 0.0, input_vec.x).normalized()

func _handle_pointer_command(event: InputEventMouseButton) -> void:
    var target: Node3D = _get_click_target(event)
    if _is_enemy_target(target):
        hero.set_attack_target(target)
        return
    var target_pos: Vector3 = _get_click_position(event)
    if target_pos != Vector3.ZERO:
        hero.clear_attack_target()
        hero.move_to(target_pos)

func _get_click_position(event: InputEventMouseButton) -> Vector3:
    if not camera or not hero:
        return Vector3.ZERO
    var viewport: Viewport = get_viewport()
    var ray_origin: Vector3 = camera.project_ray_origin(event.position)
    var ray_dir: Vector3 = camera.project_ray_normal(event.position)
    var ray_end: Vector3 = ray_origin + ray_dir * 1000.0

    # First try the actual ground collider.
    var space_state: PhysicsDirectSpaceState3D = viewport.get_world_3d().direct_space_state
    var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
    query.collision_mask = 1
    var result: Dictionary = space_state.intersect_ray(query)
    if not result.is_empty() and result.has("position"):
        var hit_pos: Vector3 = result.position
        hit_pos.y = hero.global_position.y
        return hit_pos

    # Fallback: intersect the mouse ray with the hero-height ground plane.
    # This keeps click-to-move working even if a map mesh is on a different collision layer.
    if absf(ray_dir.y) < 0.0001:
        return Vector3.ZERO
    var t: float = (hero.global_position.y - ray_origin.y) / ray_dir.y
    if t <= 0.0:
        return Vector3.ZERO
    var plane_hit: Vector3 = ray_origin + ray_dir * t
    plane_hit.y = hero.global_position.y
    return plane_hit

func _get_click_target(event: InputEventMouseButton) -> Node3D:
    if not camera or not hero:
        return null

    # 1) Screen-space pick. This is the most reliable for MOBA controls because
    #    enemies are often visually clicked on their mesh, while the capsule ray can miss.
    var screen_target: Node3D = _find_enemy_near_screen_position(event.position)
    if screen_target:
        return screen_target

    # 2) Physics ray pick against every collision layer, then climb to the unit root.
    var viewport: Viewport = get_viewport()
    var space_state: PhysicsDirectSpaceState3D = viewport.get_world_3d().direct_space_state
    var ray_origin: Vector3 = camera.project_ray_origin(event.position)
    var ray_end: Vector3 = ray_origin + camera.project_ray_normal(event.position) * 1500.0
    var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
    query.collision_mask = -1
    query.collide_with_areas = true
    query.exclude = [hero.get_rid()]
    var result: Dictionary = space_state.intersect_ray(query)
    if not result.is_empty() and result.has("collider"):
        var candidate: Node3D = result.collider as Node3D
        while candidate and not candidate.has_method("get_team") and not candidate.has_node("HealthComponent"):
            candidate = candidate.get_parent() as Node3D
        if _is_enemy_target(candidate):
            return candidate

    # 3) Ground-world fallback. If the ray hit the road/river first, select the nearest
    #    enemy around the click position with a generous MOBA selection radius.
    var click_world: Vector3 = _get_click_position(event)
    if click_world == Vector3.ZERO:
        return null
    return _find_enemy_near_world_position(click_world)

func _find_enemy_near_screen_position(screen_pos: Vector2) -> Node3D:
    if not camera or not hero:
        return null
    var best: Node3D = null
    var best_score: float = INF
    for enemy in _enemy_candidates():
        if not _is_enemy_target(enemy):
            continue
        var probe_height: float = _target_probe_height(enemy)
        var probe: Vector3 = enemy.global_position + Vector3.UP * probe_height
        if camera.is_position_behind(probe):
            continue
        var projected: Vector2 = camera.unproject_position(probe)
        var screen_distance: float = projected.distance_to(screen_pos)
        var threshold: float = _target_screen_pick_radius(enemy)
        if screen_distance > threshold:
            continue
        var world_distance: float = hero.global_position.distance_to(enemy.global_position)
        var score: float = screen_distance + world_distance * 0.85
        if score < best_score:
            best_score = score
            best = enemy
    return best

func _find_enemy_near_world_position(world_pos: Vector3) -> Node3D:
    var best: Node3D = null
    var best_dist: float = INF
    for enemy in _enemy_candidates():
        if not _is_enemy_target(enemy):
            continue
        var d: float = enemy.global_position.distance_to(world_pos)
        var pick_radius: float = _target_world_pick_radius(enemy)
        if d <= pick_radius and d < best_dist:
            best_dist = d
            best = enemy
    return best

func _enemy_candidates() -> Array[Node3D]:
    var result: Array[Node3D] = []
    if has_node("/root/TeamManager"):
        for enemy in TeamManager.get_enemies(hero.get_team()):
            if enemy is Node3D and not result.has(enemy):
                result.append(enemy as Node3D)
    var scene_root := get_tree().current_scene
    if scene_root:
        _scan_enemy_candidates(scene_root, result)
    return result

func _scan_enemy_candidates(node: Node, result: Array[Node3D]) -> void:
    if node is Node3D:
        var n := node as Node3D
        if not result.has(n) and _is_enemy_target(n):
            result.append(n)
    for child in node.get_children():
        _scan_enemy_candidates(child, result)

func _target_probe_height(target: Node3D) -> float:
    if target == null:
        return 1.0
    if target.has_meta("is_tower"):
        return 2.4
    if target.has_meta("is_nexus"):
        return 2.6
    if target.has_meta("is_minion"):
        return 0.75
    return 1.45

func _target_screen_pick_radius(target: Node3D) -> float:
    if target == null:
        return 80.0
    if target.has_meta("is_tower"):
        return 175.0
    if target.has_meta("is_nexus"):
        return 190.0
    if target.has_meta("is_minion"):
        return 125.0
    return 190.0

func _target_world_pick_radius(target: Node3D) -> float:
    if target == null:
        return 4.0
    if target.has_meta("is_tower"):
        return 10.0
    if target.has_meta("is_nexus"):
        return 12.0
    if target.has_meta("is_minion"):
        return 6.6
    return 11.0

func _is_enemy_target(target: Node3D) -> bool:
    if not hero:
        return false
    return CombatQueries.is_enemy(target, hero.get_team(), hero)

func _cast_skill_in_slot(slot_index: int) -> void:
    if not hero or not hero.has_node("SkillSlots"):
        return
    var skill_slots: Node3D = hero.get_node("SkillSlots") as Node3D
    if slot_index < 0 or slot_index >= skill_slots.get_child_count():
        return
    var skill: SkillBase = skill_slots.get_child(slot_index) as SkillBase
    if not skill:
        return
    skill.set_caster(hero)
    var target: Node3D = null
    if skill.cast_range > 0.1:
        target = hero.current_attack_target if _is_enemy_target(hero.current_attack_target) else _find_nearest_enemy_for_skill(skill.cast_range)
    skill.cast(target)

func _find_nearest_enemy_for_skill(range_limit: float) -> Node3D:
    return hero.find_nearest_enemy(range_limit)

func _focus_nearest_enemy() -> void:
    var target: Node3D = _find_nearest_enemy_for_skill(18.0)
    if target:
        hero.set_attack_target(target)
