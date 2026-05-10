# Ranged Attack / Hero Stats / GitHub Cleanup Patch

本补丁基于 `ui_economy_fountain_killfeed_fixed` 版本继续修改。

## 核心改动

- 普攻改为远程锁定弹道：普通攻击现在会发射追踪型物理投射物，不再是瞬间近战判定。
- 技能冷却缩短：Q/E/R/1/2 全部降低 CD，让战斗节奏更密集。
- 英雄选择属性对接：新增 5 套独立 `HeroStats.tres`，英雄选择会写入 `GameManager.selected_hero_class`，进入主场景后 PlayerHero 按选择加载属性。
- 新增 `scenes/ui/hero_select.tscn`，主菜单 Play 先进入英雄选择，再进入游戏。
- 商店商品来源统一：当前 HUD 商店已通过 `hero.get_shop_items()` 读取 `ItemCatalog`，不再维护旧硬编码商品数组。
- 冗余 UI 检查：旧 `battle_hud.gd / enhanced_hud.gd / simple_moba_hud.gd / minimap.gd / game_minimap_control.gd / shop_ui.gd` 已不在工程内。

## 英雄属性资源

- `resources/heroes/hero_stats_arc_knight.tres`
- `resources/heroes/hero_stats_blade_dancer.tres`
- `resources/heroes/hero_stats_star_mage.tres`
- `resources/heroes/hero_stats_thunder_archer.tres`
- `resources/heroes/hero_stats_spirit_support.tres`

## GitHub 版本清理

GitHub 包移除了本地 LLM / AI 教练相关脚本、测试场景和文档，并移除 `.uid`、`.import`、日志、缓存等生成文件。
