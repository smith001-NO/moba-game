extends Camera3D
class_name CameraController

@export var target: Node3D
@export var player_only: bool = true

@export_group("PC MOBA View")
@export var fixed_yaw_deg: float = -45.0
@export var fixed_pitch_deg: float = 58.0
@export var target_height: float = 1.0
@export var zoom_distance: float = 24.0
@export var min_zoom_distance: float = 16.0
@export var max_zoom_distance: float = 34.0
@export var zoom_step: float = 1.6
@export var pan_speed: float = 16.0
@export var edge_pan_enabled: bool = false
@export var edge_size: float = 18.0
@export var max_pan_distance_from_target: float = 42.0
@export var lock_to_hero_on_start: bool = true

var _enabled_for_player: bool = false
var _pan_offset: Vector3 = Vector3.ZERO
var _locked_to_hero: bool = true
var _last_focus: Vector3 = Vector3.ZERO

func _enter_tree() -> void:
    top_level = true

func _ready() -> void:
    top_level = true
    if not target:
        target = get_parent() as Node3D
    _enabled_for_player = _is_player_camera()
    current = _enabled_for_player
    fov = 43.0
    _locked_to_hero = lock_to_hero_on_start
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    set_process(_enabled_for_player)
    set_physics_process(false)
    set_process_unhandled_input(_enabled_for_player)
    if _enabled_for_player:
        call_deferred("_detach_to_scene")
        _update_camera(true)

func _detach_to_scene() -> void:
    if not _enabled_for_player or not get_tree().current_scene:
        return
    if get_parent() != get_tree().current_scene:
        reparent(get_tree().current_scene, true)
    top_level = true
    _update_camera(true)

func _is_player_camera() -> bool:
    if not player_only:
        return true
    if target and target.name == "PlayerHero":
        return true
    if target and target.is_in_group("player_hero"):
        return true
    return false

func activate_for_player(new_target: Node3D) -> void:
    target = new_target
    _enabled_for_player = true
    player_only = true
    current = true
    fov = 43.0
    _locked_to_hero = true
    _pan_offset = Vector3.ZERO
    top_level = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    set_process(true)
    set_physics_process(false)
    set_process_unhandled_input(true)
    call_deferred("_detach_to_scene")
    _update_camera(true)

func _unhandled_input(event: InputEvent) -> void:
    if not _enabled_for_player:
        return
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            zoom_distance = maxf(min_zoom_distance, zoom_distance - zoom_step)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            zoom_distance = minf(max_zoom_distance, zoom_distance + zoom_step)
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE:
            center_on_target(true)
        elif event.keycode == KEY_Y:
            _locked_to_hero = not _locked_to_hero
            if _locked_to_hero:
                center_on_target(true)
        elif event.keycode == KEY_C:
            reset_view()

func _process(delta: float) -> void:
    if not _enabled_for_player:
        return
    _handle_camera_pan(delta)
    _update_camera(false)

func _handle_camera_pan(delta: float) -> void:
    var pan_input: Vector2 = Vector2.ZERO
    if Input.is_key_pressed(KEY_LEFT):
        pan_input.x -= 1.0
    if Input.is_key_pressed(KEY_RIGHT):
        pan_input.x += 1.0
    if Input.is_key_pressed(KEY_UP):
        pan_input.y += 1.0
    if Input.is_key_pressed(KEY_DOWN):
        pan_input.y -= 1.0
    if edge_pan_enabled:
        var viewport_size: Vector2 = get_viewport().get_visible_rect().size
        var mouse_pos: Vector2 = get_viewport().get_mouse_position()
        if mouse_pos.x <= edge_size:
            pan_input.x -= 1.0
        elif mouse_pos.x >= viewport_size.x - edge_size:
            pan_input.x += 1.0
        if mouse_pos.y <= edge_size:
            pan_input.y += 1.0
        elif mouse_pos.y >= viewport_size.y - edge_size:
            pan_input.y -= 1.0
    if pan_input.length() <= 0.01:
        return
    _locked_to_hero = false
    pan_input = pan_input.normalized()
    _pan_offset += (_camera_right_on_ground() * pan_input.x + _camera_forward_on_ground() * pan_input.y) * pan_speed * delta
    if _pan_offset.length() > max_pan_distance_from_target:
        _pan_offset = _pan_offset.normalized() * max_pan_distance_from_target

func _update_camera(_force: bool = false) -> void:
    var focus: Vector3 = Vector3.ZERO
    if target and is_instance_valid(target):
        focus = target.global_position + Vector3.UP * target_height
    if not _locked_to_hero:
        focus += _pan_offset
    _last_focus = focus
    var desired_pos: Vector3 = focus + _fixed_camera_direction_from_focus() * zoom_distance
    global_position = desired_pos
    look_at(focus, Vector3.UP)

func _fixed_camera_direction_from_focus() -> Vector3:
    var yaw_rad: float = deg_to_rad(fixed_yaw_deg)
    var pitch_rad: float = deg_to_rad(fixed_pitch_deg)
    var horizontal: float = cos(pitch_rad)
    var vertical: float = sin(pitch_rad)
    return Vector3(cos(yaw_rad) * horizontal, vertical, sin(yaw_rad) * horizontal).normalized()

func _camera_forward_on_ground() -> Vector3:
    var forward: Vector3 = -global_transform.basis.z
    forward.y = 0.0
    if forward.length() <= 0.001:
        forward = Vector3.FORWARD
    return forward.normalized()

func _camera_right_on_ground() -> Vector3:
    var right: Vector3 = global_transform.basis.x
    right.y = 0.0
    if right.length() <= 0.001:
        right = Vector3.RIGHT
    return right.normalized()

func get_flat_forward() -> Vector3:
    return _camera_forward_on_ground()

func get_flat_right() -> Vector3:
    return _camera_right_on_ground()

func center_on_target(force: bool = false) -> void:
    _locked_to_hero = true
    _pan_offset = Vector3.ZERO
    _update_camera(force)

func reset_view() -> void:
    fixed_yaw_deg = -45.0
    fixed_pitch_deg = 58.0
    zoom_distance = 24.0
    center_on_target(true)
