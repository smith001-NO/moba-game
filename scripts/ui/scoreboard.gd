extends CanvasLayer
class_name Scoreboard

## 计分板
## 按 Tab 键显示，展示双方队伍详细数据

var is_visible = false

@onready var panel: Panel = $Panel
@onready var blue_team_container: VBoxContainer = $Panel/MarginContainer/HBoxContainer/BlueTeam/ScrollContainer/BlueList
@onready var red_team_container: VBoxContainer = $Panel/MarginContainer/HBoxContainer/RedTeam/ScrollContainer/RedList
@onready var blue_title: Label = $Panel/MarginContainer/HBoxContainer/BlueTeam/BlueTitle
@onready var red_title: Label = $Panel/MarginContainer/HBoxContainer/RedTeam/RedTitle

func _ready():
	hide()
	panel.hide()

	# 设置标题
	blue_title.text = "Blue Team"
	red_title.text = "Red Team"

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		if not is_visible:
			show_scoreboard()
		else:
			hide_scoreboard()
	elif event is InputEventKey and not event.pressed and event.keycode == KEY_TAB:
		# Tab 释放时隐藏
		if is_visible:
			hide_scoreboard()

func show_scoreboard():
	is_visible = true
	show()
	panel.show()
	_refresh_data()

func hide_scoreboard():
	is_visible = false
	hide()
	panel.hide()

func _refresh_data():
	# 清除旧数据
	for child in blue_team_container.get_children():
		child.queue_free()
	for child in red_team_container.get_children():
		child.queue_free()

	# 填充蓝队
	var blue_units = TeamManager.get_team_units(GameManager.Team.BLUE)
	for unit in blue_units:
		var row = _create_unit_row(unit, Color(0.4, 0.6, 1.0))
		blue_team_container.add_child(row)

	# 填充红队
	var red_units = TeamManager.get_team_units(GameManager.Team.RED)
	for unit in red_units:
		var row = _create_unit_row(unit, Color(1.0, 0.4, 0.4))
		red_team_container.add_child(row)

func _create_unit_row(unit: Node3D, color: Color) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 30)

	var name_label = Label.new()
	if unit is HeroBase and unit.stats:
		name_label.text = unit.stats.hero_name
	elif unit.has_meta("unit_name"):
		name_label.text = unit.get_meta("unit_name")
	else:
		name_label.text = unit.name

	name_label.custom_minimum_size = Vector2(120, 0)
	name_label.modulate = color
	row.add_child(name_label)

	# 占位数据（后续可扩展）
	var level_label = Label.new()
	level_label.text = "Lv.1"
	level_label.custom_minimum_size = Vector2(40, 0)
	row.add_child(level_label)

	var hp_label = Label.new()
	if unit is HeroBase:
		hp_label.text = "HP: %d/%d" % [int(unit.current_hp), int(unit.stats.max_hp)]
	else:
		hp_label.text = "HP: --"
	hp_label.custom_minimum_size = Vector2(80, 0)
	row.add_child(hp_label)

	return row
