extends Control
class_name MinimapView

@export var map_half_extent: float = 60.0
@export var player: Node3D

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    set_process(true)

func set_player(node: Node3D) -> void:
    player = node

func _process(_delta: float) -> void:
    queue_redraw()

func _draw() -> void:
    var rect := Rect2(Vector2.ZERO, size)
    draw_rect(rect, Color(0.02, 0.04, 0.06, 0.78), true)
    draw_rect(rect, Color(0.24, 0.52, 0.78, 0.75), false, 2.0)
    draw_line(_world_to_map(Vector3(-50, 0, 0)), _world_to_map(Vector3(50, 0, 0)), Color(0.65, 0.60, 0.50, 0.85), 5.0)
    draw_line(_world_to_map(Vector3(0, 0, -55)), _world_to_map(Vector3(0, 0, 55)), Color(0.10, 0.45, 0.75, 0.75), 4.0)
    draw_circle(_world_to_map(Vector3(0, 0, 0)), 9.0, Color(0.30, 0.70, 1.0, 0.28))

    _draw_structure(Vector3(-42, 0, 0), Color(0.18, 0.52, 1.0, 1.0), 7.0)
    _draw_structure(Vector3(42, 0, 0), Color(1.0, 0.20, 0.16, 1.0), 7.0)
    for x in [-27, -12]:
        _draw_structure(Vector3(float(x), 0, 0), Color(0.18, 0.52, 1.0, 1.0), 4.5)
    for x in [12, 27]:
        _draw_structure(Vector3(float(x), 0, 0), Color(1.0, 0.20, 0.16, 1.0), 4.5)

    if has_node("/root/TeamManager"):
        for unit in TeamManager.get_team_units(GameManager.Team.BLUE):
            _draw_unit(unit, Color(0.22, 0.58, 1.0, 1.0), 3.2)
        for unit in TeamManager.get_team_units(GameManager.Team.RED):
            _draw_unit(unit, Color(1.0, 0.24, 0.16, 1.0), 3.2)
    if player and is_instance_valid(player):
        draw_circle(_world_to_map(player.global_position), 5.5, Color(1.0, 1.0, 0.35, 1.0))

func _draw_structure(pos: Vector3, color: Color, radius: float) -> void:
    draw_circle(_world_to_map(pos), radius, color)
    draw_circle(_world_to_map(pos), radius + 1.5, Color(color.r, color.g, color.b, 0.20))

func _draw_unit(unit: Node3D, color: Color, radius: float) -> void:
    if not unit or not is_instance_valid(unit):
        return
    if unit.has_method("is_alive") and not unit.is_alive():
        return
    var draw_radius := radius
    if unit.has_meta("is_minion"):
        draw_radius = 2.0
    elif unit.has_meta("is_tower") or unit.has_meta("is_nexus"):
        return
    draw_circle(_world_to_map(unit.global_position), draw_radius, color)

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if not player or not is_instance_valid(player):
            return
        if player.has_method("move_to"):
            player.move_to(_map_to_world(event.position))
            get_viewport().set_input_as_handled()

func _world_to_map(world: Vector3) -> Vector2:
    var nx: float = clampf((world.x + map_half_extent) / (map_half_extent * 2.0), 0.0, 1.0)
    var ny: float = clampf((world.z + map_half_extent) / (map_half_extent * 2.0), 0.0, 1.0)
    return Vector2(nx * size.x, ny * size.y)

func _map_to_world(pos: Vector2) -> Vector3:
    var nx: float = clampf(pos.x / maxf(size.x, 1.0), 0.0, 1.0)
    var ny: float = clampf(pos.y / maxf(size.y, 1.0), 0.0, 1.0)
    return Vector3(nx * map_half_extent * 2.0 - map_half_extent, 0.6, ny * map_half_extent * 2.0 - map_half_extent)
