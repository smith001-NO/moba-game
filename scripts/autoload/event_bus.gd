extends Node

# 战斗事件
@warning_ignore("unused_signal")
signal unit_died(unit: Node3D, killer: Node3D)
@warning_ignore("unused_signal")
signal skill_cast(caster: Node3D, skill_name: String)

# 小兵事件
@warning_ignore("unused_signal")
signal minion_killed(minion: Node3D, killer: Node3D)

# 建筑事件
@warning_ignore("unused_signal")
signal tower_destroyed(tower: Node3D, team: int)
@warning_ignore("unused_signal")
signal nexus_destroyed(nexus: Node3D, team: int)

# 英雄成长/播报事件
@warning_ignore("unused_signal")
signal hero_killed(victim: Node3D, killer: Node3D, streak: int, revenge: bool)
@warning_ignore("unused_signal")
signal hero_level_changed(hero: Node3D, new_level: int)
@warning_ignore("unused_signal")
signal hero_economy_changed(hero: Node3D)
