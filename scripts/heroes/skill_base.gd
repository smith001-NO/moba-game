extends Node
class_name SkillBase

signal skill_cast(skill: SkillBase, caster: Node3D, target: Node3D)
signal cooldown_started(cooldown_remaining: float)

@export var skill_name: String = "Skill"
@export_multiline var description: String = ""
@export var cooldown: float = 5.0
@export var mana_cost: float = 30.0
@export var cast_range: float = 10.0
@export var damage: float = 100.0
@export var icon: Texture2D

var is_on_cooldown: bool = false
var _cooldown_timer: float = 0.0
var _caster: Node3D = null

func _process(delta: float) -> void:
    if is_on_cooldown:
        _cooldown_timer -= delta
        if _cooldown_timer <= 0.0:
            is_on_cooldown = false
            _on_cooldown_timeout()

func set_caster(caster: Node3D) -> void:
    _caster = caster

func get_caster() -> Node3D:
    return _caster

func can_cast(target: Node3D) -> Dictionary:
    if is_on_cooldown:
        return {"can_cast": false, "reason": "cooldown"}
    if not _caster:
        return {"can_cast": false, "reason": "no caster"}
    var hero = _caster as HeroBase
    if hero and hero.current_mp < mana_cost:
        return {"can_cast": false, "reason": "not enough mana"}
    if target and _caster.global_position.distance_to(target.global_position) > cast_range:
        return {"can_cast": false, "reason": "out of range"}
    return {"can_cast": true, "reason": ""}

func cast(target: Node3D) -> bool:
    var check = can_cast(target)
    if not check["can_cast"]:
        return false
    var hero = _caster as HeroBase
    if hero and mana_cost > 0.0:
        if not hero.consume_mana(mana_cost):
            return false
    start_cooldown()
    _apply_skill(target)
    skill_cast.emit(self, _caster, target)
    if has_node("/root/EventBus"):
        EventBus.skill_cast.emit(_caster, skill_name)
    return true

func start_cooldown() -> void:
    is_on_cooldown = true
    _cooldown_timer = cooldown
    cooldown_started.emit(cooldown)

func get_cooldown_remaining() -> float:
    return maxf(_cooldown_timer, 0.0) if is_on_cooldown else 0.0

func get_cooldown_progress() -> float:
    if cooldown <= 0.0:
        return 0.0
    return clampf(get_cooldown_remaining() / cooldown, 0.0, 1.0)

func _apply_skill(_target: Node3D) -> void:
    pass

func _on_cooldown_timeout() -> void:
    pass
