extends Node

var _blue_units: Array[Node3D] = []
var _red_units: Array[Node3D] = []

signal unit_registered(unit: Node3D, team: GameManager.Team)
signal unit_unregistered(unit: Node3D, team: GameManager.Team)

func get_team_units(team: GameManager.Team) -> Array[Node3D]:
    _prune_invalid()
    match team:
        GameManager.Team.BLUE:
            return _blue_units.duplicate()
        GameManager.Team.RED:
            return _red_units.duplicate()
        _:
            return []

func get_enemies(team: GameManager.Team) -> Array[Node3D]:
    _prune_invalid()
    match team:
        GameManager.Team.BLUE:
            return _red_units.duplicate()
        GameManager.Team.RED:
            return _blue_units.duplicate()
        _:
            return []

func get_allies(team: GameManager.Team) -> Array[Node3D]:
    return get_team_units(team)

func register_unit(unit: Node3D, team: GameManager.Team) -> void:
    if not unit or team == GameManager.Team.NEUTRAL:
        return
    _prune_invalid()
    var list: Array[Node3D] = _blue_units if team == GameManager.Team.BLUE else _red_units
    if list.has(unit):
        return
    list.append(unit)
    unit_registered.emit(unit, team)

func unregister_unit(unit: Node3D, team: GameManager.Team) -> void:
    if not unit:
        return
    var removed = false
    match team:
        GameManager.Team.BLUE:
            removed = _blue_units.has(unit)
            _blue_units.erase(unit)
        GameManager.Team.RED:
            removed = _red_units.has(unit)
            _red_units.erase(unit)
        _:
            pass
    if removed:
        unit_unregistered.emit(unit, team)

func clear_all() -> void:
    _blue_units.clear()
    _red_units.clear()

func _prune_invalid() -> void:
    var clean_blue: Array[Node3D] = []
    for unit in _blue_units:
        if is_instance_valid(unit):
            clean_blue.append(unit)
    var clean_red: Array[Node3D] = []
    for unit in _red_units:
        if is_instance_valid(unit):
            clean_red.append(unit)
    _blue_units = clean_blue
    _red_units = clean_red
