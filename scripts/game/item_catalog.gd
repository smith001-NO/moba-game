extends RefCounted
class_name ItemCatalog

# Rebalanced for a high-HP PC MOBA prototype:
# base hero HP ~4000, level-15 HP ~13000 before items, and 15000-22000 with tank builds.
static func get_items() -> Array[Dictionary]:
    return [
        {"id":"starter_blade", "name":"开锋剑", "cost":650, "attack":95.0, "hp":250.0, "mp":0.0, "defense":0.0, "attack_speed":0.08, "range":0.0, "move_speed":0.0, "hp_regen":0.0, "mp_regen":0.0, "desc":"攻击 +95 / 生命 +250 / 攻速 +0.08"},
        {"id":"cloud_boots", "name":"踏云战靴", "cost":850, "attack":35.0, "hp":450.0, "mp":0.0, "defense":10.0, "attack_speed":0.15, "range":0.0, "move_speed":0.95, "hp_regen":0.0, "mp_regen":0.0, "desc":"移速 +0.95 / 攻速 +0.15 / 生命 +450"},
        {"id":"jade_guard", "name":"玄玉战甲", "cost":1050, "attack":0.0, "hp":1550.0, "mp":0.0, "defense":50.0, "attack_speed":0.0, "range":0.0, "move_speed":0.0, "hp_regen":20.0, "mp_regen":0.0, "desc":"生命 +1550 / 防御 +50 / 回血 +20"},
        {"id":"spirit_edge", "name":"灵魄刃", "cost":1200, "attack":165.0, "hp":600.0, "mp":0.0, "defense":0.0, "attack_speed":0.22, "range":0.0, "move_speed":0.0, "hp_regen":0.0, "mp_regen":0.0, "desc":"攻击 +165 / 生命 +600 / 攻速 +0.22"},
        {"id":"phoenix_seal", "name":"凤鸣法印", "cost":1300, "attack":70.0, "hp":950.0, "mp":620.0, "defense":0.0, "attack_speed":0.0, "range":0.0, "move_speed":0.0, "hp_regen":18.0, "mp_regen":24.0, "desc":"生命/法力/回复全面提升"},
        {"id":"thunder_bow", "name":"雷纹长弓", "cost":1500, "attack":120.0, "hp":500.0, "mp":0.0, "defense":0.0, "attack_speed":0.35, "range":1.55, "move_speed":0.0, "hp_regen":0.0, "mp_regen":0.0, "desc":"攻击 +120 / 射程 +1.55 / 攻速 +0.35"},
        {"id":"dragon_heart", "name":"苍龙心", "cost":1800, "attack":0.0, "hp":2850.0, "mp":0.0, "defense":35.0, "attack_speed":0.0, "range":0.0, "move_speed":0.0, "hp_regen":44.0, "mp_regen":0.0, "desc":"生命 +2850 / 防御 +35 / 回血 +44"},
        {"id":"immortal_edge", "name":"诛仙锋", "cost":2300, "attack":260.0, "hp":1200.0, "mp":0.0, "defense":25.0, "attack_speed":0.18, "range":0.0, "move_speed":0.0, "hp_regen":0.0, "mp_regen":0.0, "desc":"攻击 +260 / 生命 +1200 / 防御 +25"},
        {"id":"heavenly_aegis", "name":"天罡玄盾", "cost":2600, "attack":35.0, "hp":3600.0, "mp":300.0, "defense":80.0, "attack_speed":0.0, "range":0.0, "move_speed":0.0, "hp_regen":55.0, "mp_regen":10.0, "desc":"后期肉装：生命 +3600 / 防御 +80"},
        {"id":"starbreaker", "name":"破星神兵", "cost":3000, "attack":360.0, "hp":1500.0, "mp":250.0, "defense":20.0, "attack_speed":0.25, "range":0.35, "move_speed":0.0, "hp_regen":10.0, "mp_regen":8.0, "desc":"后期输出：攻击 +360 / 生命 +1500"},
    ]

static func get_item(id: String) -> Dictionary:
    for item in get_items():
        if String(item.get("id", "")) == id:
            return item
    return {}

static func summarize(item: Dictionary) -> String:
    if item.is_empty():
        return ""
    return "%s  %dg\n%s" % [String(item.get("name", "Item")), int(item.get("cost", 0)), String(item.get("desc", ""))]
