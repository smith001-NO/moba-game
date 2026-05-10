extends Node3D
class_name Damageable

func get_defense() -> float:
    return 0.0

func get_magic_resistance() -> float:
    return get_defense() * 0.65

func get_team() -> GameManager.Team:
    return GameManager.Team.NEUTRAL

func is_alive() -> bool:
    return true

func take_damage(_amount: float, _attacker: Node3D = null) -> void:
    pass
