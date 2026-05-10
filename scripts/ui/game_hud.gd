extends CanvasLayer

const MinimapView = preload("res://scripts/ui/minimap_view.gd")

@onready var title_label: Label = $TopBar/TitleLabel
@onready var controls_label: Label = $ControlsPanel/ControlsLabel
@onready var objective_label: Label = $ObjectivePanel/ObjectiveLabel
@onready var skill_label: Label = $SkillPanel/SkillLabel

var _player: HeroBase = null
var _player_kills: int = 0
var _minimap: MinimapView = null
var _shop_panel: Panel = null
var _shop_grid: GridContainer = null
var _shop_info: Label = null
var _shop_open: bool = false

var _economy_panel: Panel = null
var _economy_label: Label = null
var _banner_label: Label = null
var _banner_timer: float = 0.0
var _skill_icon_panel: Panel = null
var _skill_icon_labels: Array[Label] = []

func _ready() -> void:
    _set_non_interactive_hud_to_ignore_mouse()
    controls_label.text = "WASD移动英雄 | 左/右键地面移动 | 左/右键敌人远程普攻 | B打开装备商店\n方向键移动镜头 | 滚轮缩放 | Space回到英雄 | Y锁定/解锁跟随 | F锁定最近敌人 | Q/E/R/1/2技能 | 小地图点击移动 | P暂停"
    if has_node("/root/EventBus"):
        if not EventBus.minion_killed.is_connected(_on_minion_killed):
            EventBus.minion_killed.connect(_on_minion_killed)
        if EventBus.has_signal("hero_killed") and not EventBus.hero_killed.is_connected(_on_hero_killed):
            EventBus.hero_killed.connect(_on_hero_killed)
        if EventBus.has_signal("hero_level_changed") and not EventBus.hero_level_changed.is_connected(_on_hero_level_changed):
            EventBus.hero_level_changed.connect(_on_hero_level_changed)
    if has_node("/root/GameManager") and not GameManager.game_ended.is_connected(_on_game_ended):
        GameManager.game_ended.connect(_on_game_ended)
    _create_minimap()
    _create_shop()
    _create_economy_panel()
    _create_skill_icon_bar()
    _create_kill_banner()

func _set_non_interactive_hud_to_ignore_mouse() -> void:
    _set_mouse_ignore_recursive(self)

func _set_mouse_ignore_recursive(node: Node) -> void:
    for child in node.get_children():
        if child is Control:
            (child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
        _set_mouse_ignore_recursive(child)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_B:
            _toggle_shop()

func _process(delta: float) -> void:
    if not _player or not is_instance_valid(_player):
        _player = get_tree().get_first_node_in_group("player_hero") as HeroBase
        if _minimap:
            _minimap.set_player(_player)
        _refresh_shop_buttons()
    _update_title()
    _update_objective()
    _update_skills()
    _update_skill_icons()
    _update_shop_info()
    _update_economy_panel()
    _update_kill_banner(delta)

func _create_minimap() -> void:
    if _minimap:
        return
    var panel := Panel.new()
    panel.name = "MinimapPanel"
    panel.anchor_left = 1.0
    panel.anchor_top = 0.0
    panel.anchor_right = 1.0
    panel.anchor_bottom = 0.0
    panel.offset_left = -250.0
    panel.offset_top = 78.0
    panel.offset_right = -18.0
    panel.offset_bottom = 310.0
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(panel)

    var label := Label.new()
    label.name = "MinimapTitle"
    label.text = "TACTICAL MAP"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.anchor_right = 1.0
    label.offset_top = 5.0
    label.offset_bottom = 28.0
    label.add_theme_font_size_override("font_size", 14)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(label)

    _minimap = MinimapView.new()
    _minimap.name = "Minimap"
    _minimap.anchor_left = 0.0
    _minimap.anchor_top = 0.0
    _minimap.anchor_right = 1.0
    _minimap.anchor_bottom = 1.0
    _minimap.offset_left = 8.0
    _minimap.offset_top = 30.0
    _minimap.offset_right = -8.0
    _minimap.offset_bottom = -8.0
    panel.add_child(_minimap)

func _create_shop() -> void:
    _shop_panel = Panel.new()
    _shop_panel.name = "EquipmentShop"
    _shop_panel.anchor_left = 0.5
    _shop_panel.anchor_top = 0.5
    _shop_panel.anchor_right = 0.5
    _shop_panel.anchor_bottom = 0.5
    _shop_panel.offset_left = -360.0
    _shop_panel.offset_top = -260.0
    _shop_panel.offset_right = 360.0
    _shop_panel.offset_bottom = 260.0
    _shop_panel.visible = false
    _shop_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(_shop_panel)

    var title := Label.new()
    title.text = "装备商店  (B关闭)"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.anchor_right = 1.0
    title.offset_top = 12.0
    title.offset_bottom = 42.0
    title.add_theme_font_size_override("font_size", 24)
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _shop_panel.add_child(title)

    _shop_info = Label.new()
    _shop_info.anchor_left = 0.0
    _shop_info.anchor_top = 0.0
    _shop_info.anchor_right = 1.0
    _shop_info.offset_left = 18.0
    _shop_info.offset_top = 48.0
    _shop_info.offset_right = -18.0
    _shop_info.offset_bottom = 86.0
    _shop_info.add_theme_font_size_override("font_size", 17)
    _shop_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _shop_panel.add_child(_shop_info)

    _shop_grid = GridContainer.new()
    _shop_grid.columns = 2
    _shop_grid.anchor_left = 0.0
    _shop_grid.anchor_top = 0.0
    _shop_grid.anchor_right = 1.0
    _shop_grid.anchor_bottom = 1.0
    _shop_grid.offset_left = 18.0
    _shop_grid.offset_top = 96.0
    _shop_grid.offset_right = -18.0
    _shop_grid.offset_bottom = -18.0
    _shop_panel.add_child(_shop_grid)

func _create_economy_panel() -> void:
    _economy_panel = Panel.new()
    _economy_panel.name = "EconomyPanel"
    _economy_panel.anchor_left = 0.0
    _economy_panel.anchor_top = 0.0
    _economy_panel.anchor_right = 0.0
    _economy_panel.anchor_bottom = 0.0
    _economy_panel.offset_left = 18.0
    _economy_panel.offset_top = 78.0
    _economy_panel.offset_right = 520.0
    _economy_panel.offset_bottom = 280.0
    _economy_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_economy_panel)

    _economy_label = Label.new()
    _economy_label.anchor_left = 0.0
    _economy_label.anchor_top = 0.0
    _economy_label.anchor_right = 1.0
    _economy_label.anchor_bottom = 1.0
    _economy_label.offset_left = 12.0
    _economy_label.offset_top = 10.0
    _economy_label.offset_right = -12.0
    _economy_label.offset_bottom = -10.0
    _economy_label.add_theme_font_size_override("font_size", 15)
    _economy_label.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0, 1.0))
    _economy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _economy_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _economy_panel.add_child(_economy_label)

func _create_skill_icon_bar() -> void:
    _skill_icon_panel = Panel.new()
    _skill_icon_panel.name = "SkillIconBar"
    _skill_icon_panel.anchor_left = 0.5
    _skill_icon_panel.anchor_top = 1.0
    _skill_icon_panel.anchor_right = 0.5
    _skill_icon_panel.anchor_bottom = 1.0
    _skill_icon_panel.offset_left = -330.0
    _skill_icon_panel.offset_top = -154.0
    _skill_icon_panel.offset_right = 330.0
    _skill_icon_panel.offset_bottom = -76.0
    _skill_icon_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_skill_icon_panel)

    var hbox := HBoxContainer.new()
    hbox.anchor_left = 0.0
    hbox.anchor_top = 0.0
    hbox.anchor_right = 1.0
    hbox.anchor_bottom = 1.0
    hbox.offset_left = 10.0
    hbox.offset_top = 8.0
    hbox.offset_right = -10.0
    hbox.offset_bottom = -8.0
    hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hbox.add_theme_constant_override("separation", 8)
    _skill_icon_panel.add_child(hbox)

    var keys: Array[String] = ["Q", "E", "R", "1", "2"]
    var icons: Array[String] = ["✦", "➤", "✚", "☾", "⚡"]
    for i in range(5):
        var slot := Label.new()
        slot.custom_minimum_size = Vector2(118, 58)
        slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        slot.text = "%s\n[%s]" % [icons[i], keys[i]]
        slot.add_theme_font_size_override("font_size", 20)
        slot.add_theme_color_override("font_color", Color(1.0, 0.90, 0.62, 1.0))
        slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
        hbox.add_child(slot)
        _skill_icon_labels.append(slot)

func _create_kill_banner() -> void:
    _banner_label = Label.new()
    _banner_label.name = "KillBanner"
    _banner_label.anchor_left = 0.5
    _banner_label.anchor_top = 0.0
    _banner_label.anchor_right = 0.5
    _banner_label.anchor_bottom = 0.0
    _banner_label.offset_left = -430.0
    _banner_label.offset_top = 78.0
    _banner_label.offset_right = 430.0
    _banner_label.offset_bottom = 136.0
    _banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _banner_label.add_theme_font_size_override("font_size", 32)
    _banner_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.22, 1.0))
    _banner_label.text = ""
    _banner_label.visible = false
    _banner_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_banner_label)

func _refresh_shop_buttons() -> void:
    if not _shop_grid:
        return
    for child in _shop_grid.get_children():
        child.queue_free()
    if not _player:
        return
    var items: Array = _player.get_shop_items()
    for i in range(items.size()):
        var item: Dictionary = items[i]
        var btn := Button.new()
        btn.custom_minimum_size = Vector2(320, 78)
        btn.text = "%s  %dG\n%s" % [str(item.get("name", "Item")), int(item.get("cost", 0)), str(item.get("desc", ""))]
        btn.mouse_filter = Control.MOUSE_FILTER_STOP
        btn.pressed.connect(_buy_item.bind(i))
        _shop_grid.add_child(btn)

func _toggle_shop() -> void:
    _shop_open = not _shop_open
    if _shop_panel:
        _shop_panel.visible = _shop_open
        if _shop_open:
            _refresh_shop_buttons()

func _buy_item(index: int) -> void:
    if not _player:
        return
    var ok: bool = _player.buy_shop_item(index)
    if _shop_info:
        _shop_info.text = "购买成功，属性已提升。" if ok else "金币不足或装备栏已满。"
    _refresh_shop_buttons()

func _update_shop_info() -> void:
    if not _shop_info or not _player:
        return
    _shop_info.text = "金币: %d | 等级: %d | 总经济: %d | 已购: %s" % [_player.gold, _player.level, _player.get_net_worth(), _player.get_inventory_names()]

func _update_title() -> void:
    if GameManager.current_state == GameManager.GameState.GAME_OVER:
        return
    var state_text: String = "Destroy the red core"
    if GameManager.current_state == GameManager.GameState.PAUSED:
        state_text = "PAUSED"
    title_label.text = "Modern MOBA Arena  |  %s  |  %s" % [GameManager.get_formatted_time(), state_text]

func _update_objective() -> void:
    var lines: Array[String] = []
    lines.append("Blue %d : Red %d" % [GameManager.team_scores["blue"], GameManager.team_scores["red"]])
    if _player and is_instance_valid(_player):
        lines.append("Hero kills: %d  Streak: %d  Minion kills: %d" % [_player.total_kills, _player.kill_streak, _player.total_minion_kills])
        lines.append("Lv.%d/15  XP %.0f/%.0f  Gold %d  Economy %d" % [_player.level, _player.xp, _player.xp_to_next, _player.gold, _player.get_net_worth()])
        lines.append("HP %.0f/%.0f  MP %.0f/%.0f  ATK %.0f DEF %.0f" % [_player.current_hp, _player.stats.max_hp, _player.current_mp, _player.stats.max_mp, _player.stats.attack_damage, _player.stats.defense])
        if _player.current_attack_target and is_instance_valid(_player.current_attack_target):
            lines.append("Target: %s" % _describe_target(_player.current_attack_target))
        else:
            lines.append("Target: none - click an enemy or press F to lock nearest")
    lines.append("泉水范围内每秒回复 10% 最大生命 / 16% 最大法力。")
    objective_label.text = "\n".join(lines)

func _update_skills() -> void:
    if not _player or not _player.has_node("SkillSlots"):
        skill_label.text = "Q Arc Volley | E Phantom Steps | R Renewal | 1 Crescent Slash | 2 Thunder Field"
        return
    var names: Array[String] = ["Q", "E", "R", "1", "2"]
    var parts: Array[String] = []
    var slots: Node = _player.get_node("SkillSlots")
    for i in range(min(5, slots.get_child_count())):
        var skill := slots.get_child(i) as SkillBase
        if skill:
            var cd: float = skill.get_cooldown_remaining()
            var text: String = "%s %s" % [names[i], skill.skill_name]
            if cd > 0.05:
                text += " %.1fs" % cd
            parts.append(text)
    skill_label.text = "  |  ".join(parts)

func _update_skill_icons() -> void:
    if not _player or not _player.has_node("SkillSlots"):
        return
    var keys: Array[String] = ["Q", "E", "R", "1", "2"]
    var icons: Array[String] = ["✦", "➤", "✚", "☾", "⚡"]
    var slots: Node = _player.get_node("SkillSlots")
    for i in range(min(_skill_icon_labels.size(), slots.get_child_count())):
        var label: Label = _skill_icon_labels[i]
        var skill := slots.get_child(i) as SkillBase
        if not skill:
            continue
        var cd: float = skill.get_cooldown_remaining()
        if cd > 0.05:
            label.text = "%s\n[%s] %.1f" % [icons[i], keys[i], cd]
            label.add_theme_color_override("font_color", Color(0.62, 0.68, 0.78, 1.0))
        else:
            label.text = "%s\n[%s]" % [icons[i], keys[i]]
            label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.62, 1.0))

func _update_economy_panel() -> void:
    if not _economy_label:
        return
    var heroes: Array[HeroBase] = _collect_heroes()
    heroes.sort_custom(Callable(self, "_sort_heroes_by_economy"))
    var lines: Array[String] = []
    lines.append("经济面板  Economy / Lv / Gold / Items")
    for hero in heroes:
        var alive_mark: String = "●" if hero.is_alive() else "×"
        var team_mark: String = "蓝" if hero.get_team() == GameManager.Team.BLUE else "红"
        var item_text: String = hero.get_inventory_names()
        if item_text.length() > 34:
            item_text = item_text.substr(0, 31) + "..."
        lines.append("%s %s %-12s  Lv.%02d  %5d  G:%4d  %s" % [alive_mark, team_mark, hero.get_display_name(), hero.level, hero.get_net_worth(), hero.gold, item_text])
    _economy_label.text = "\n".join(lines)

func _collect_heroes() -> Array[HeroBase]:
    var heroes: Array[HeroBase] = []
    if has_node("/root/TeamManager"):
        for unit in TeamManager.get_team_units(GameManager.Team.BLUE):
            if unit is HeroBase and not heroes.has(unit):
                heroes.append(unit as HeroBase)
        for unit in TeamManager.get_team_units(GameManager.Team.RED):
            if unit is HeroBase and not heroes.has(unit):
                heroes.append(unit as HeroBase)
    return heroes

func _sort_heroes_by_economy(a: HeroBase, b: HeroBase) -> bool:
    if a.get_net_worth() == b.get_net_worth():
        return a.level > b.level
    return a.get_net_worth() > b.get_net_worth()

func _describe_target(target: Node3D) -> String:
    var hp_text: String = "HP ?"
    if target.has_node("HealthComponent"):
        var health := target.get_node("HealthComponent") as HealthComponent
        hp_text = "HP %.0f/%.0f" % [health.current_hp, health.max_hp]
    elif target is HeroBase:
        var hero_target := target as HeroBase
        hp_text = "HP %.0f/%.0f" % [hero_target.current_hp, hero_target.stats.max_hp]
    var team_text: String = "BLUE"
    if target.has_method("get_team") and target.get_team() == GameManager.Team.RED:
        team_text = "RED"
    return "%s [%s] %s" % [target.name, team_text, hp_text]

func _on_minion_killed(_minion: Node3D, killer: Node3D) -> void:
    if _player and killer == _player:
        _player_kills += 1

func _on_hero_killed(victim: Node3D, killer: Node3D, streak: int, revenge: bool) -> void:
    var killer_name: String = killer.name if killer else "Unknown"
    var victim_name: String = victim.name if victim else "Unknown"
    if killer and killer.has_method("get_display_name"):
        killer_name = killer.call("get_display_name")
    if victim and victim.has_method("get_display_name"):
        victim_name = victim.call("get_display_name")
    var text: String = "%s 击败 %s" % [killer_name, victim_name]
    if revenge:
        text = "复仇！ " + text
    elif streak >= 5:
        text = "超神！ %s 已 %d 连杀" % [killer_name, streak]
    elif streak >= 4:
        text = "主宰比赛！ %s 四连杀" % killer_name
    elif streak >= 3:
        text = "大杀特杀！ %s 三连杀" % killer_name
    elif streak >= 2:
        text = "双杀！ %s" % killer_name
    _show_kill_banner(text, Color(1.0, 0.68, 0.18, 1.0), 2.8)

func _on_hero_level_changed(hero: Node3D, new_level: int) -> void:
    if hero == _player:
        _show_kill_banner("等级提升！ Lv.%d" % new_level, Color(0.38, 0.86, 1.0, 1.0), 1.8)

func _show_kill_banner(text: String, color: Color, duration: float) -> void:
    if not _banner_label:
        return
    _banner_label.text = text
    _banner_label.add_theme_color_override("font_color", color)
    _banner_label.visible = true
    _banner_timer = duration

func _update_kill_banner(delta: float) -> void:
    if not _banner_label or not _banner_label.visible:
        return
    _banner_timer -= delta
    if _banner_timer <= 0.0:
        _banner_label.visible = false
        _banner_label.text = ""

func _on_game_ended(winner: GameManager.Team) -> void:
    title_label.text = "VICTORY - Blue core stands" if winner == GameManager.Team.BLUE else "DEFEAT - Red wins"
