extends Node
class_name HealthComponent

signal health_changed(current: float, max: float)
signal died()

@export var max_hp: float = 100.0:
    set(value):
        max_hp = maxf(value, 1.0)
        current_hp = minf(current_hp, max_hp)

var current_hp: float = 100.0:
    set(value):
        if is_dead and value < current_hp:
            return
        current_hp = clampf(value, 0.0, max_hp)
        health_changed.emit(current_hp, max_hp)
        if current_hp <= 0.0 and not is_dead:
            die()

var is_dead: bool = false

func _ready() -> void:
    current_hp = max_hp

func take_damage(amount: float, damage_type: DamageSystem.DamageType, attack_stat: float = 0.0, defense_stat: float = 0.0) -> float:
    if is_dead:
        return 0.0
    var final_damage = DamageSystem.calculate_damage(attack_stat, defense_stat, amount, damage_type)
    current_hp -= final_damage
    return final_damage

func take_raw_damage(amount: float) -> float:
    if is_dead:
        return 0.0
    var final_damage = maxf(amount, 0.0)
    current_hp -= final_damage
    return final_damage

func heal(amount: float) -> float:
    if is_dead:
        return 0.0
    var before = current_hp
    current_hp += maxf(amount, 0.0)
    return current_hp - before

func die() -> void:
    if is_dead:
        return
    is_dead = true
    current_hp = 0.0
    died.emit()

func reset() -> void:
    is_dead = false
    current_hp = max_hp
