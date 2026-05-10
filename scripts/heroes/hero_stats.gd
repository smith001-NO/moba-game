extends Resource
class_name HeroStats

## 英雄基础属性资源
## 用于在编辑器中配置英雄的各项属性数值

## 英雄名称
@export var hero_name: String = "Hero"

## 属性值
@export_group("生命值")
@export var max_hp: float = 1000.0           # 最大生命值
@export var hp_regen: float = 5.0            # 生命恢复（每秒）

@export_group("法力值")
@export var max_mp: float = 500.0            # 最大法力值
@export var mp_regen: float = 3.0            # 法力恢复（每秒）

@export_group("战斗属性")
@export var attack_damage: float = 50.0      # 攻击力
@export var defense: float = 20.0            # 防御力
@export var attack_speed: float = 1.0        # 攻击速度（攻击/秒）
@export var attack_range: float = 2.0        # 攻击范围（单位）

@export_group("移动")
@export var move_speed: float = 5.0          # 移动速度
