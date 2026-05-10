extends CanvasLayer
class_name HeroSelectScreen

signal hero_selected(hero_name: String)
signal game_started

const HERO_DATA: Dictionary = {
    "arc_knight": {"name":"Arc Knight", "desc":"Balanced ranged knight. High durability and stable damage.", "role":"Fighter", "difficulty":1},
    "blade_dancer": {"name":"Blade Dancer", "desc":"Fast ranged duelist. Lower HP but higher attack speed.", "role":"Assassin", "difficulty":3},
    "storm_mage": {"name":"Storm Mage", "desc":"Long-range spell user with high mana and burst windows.", "role":"Mage", "difficulty":2},
    "dawn_ranger": {"name":"Dawn Ranger", "desc":"Marksman with the longest basic attack range.", "role":"Marksman", "difficulty":2},
    "jade_guardian": {"name":"Jade Guardian", "desc":"Defensive ranged guardian. High HP and defense.", "role":"Tank", "difficulty":1},
}

var selected_hero: String = "arc_knight"

@onready var hero_grid: GridContainer = $ColorRect/MarginContainer/VBoxContainer/HeroGrid
@onready var hero_name_label: Label = $ColorRect/MarginContainer/VBoxContainer/InfoPanel/HeroName
@onready var hero_desc_label: Label = $ColorRect/MarginContainer/VBoxContainer/InfoPanel/HeroDescription
@onready var hero_role_label: Label = $ColorRect/MarginContainer/VBoxContainer/InfoPanel/HeroRole
@onready var confirm_button: Button = $ColorRect/MarginContainer/VBoxContainer/ConfirmButton
@onready var back_button: Button = $ColorRect/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
    confirm_button.disabled = false
    confirm_button.pressed.connect(_on_confirm_pressed)
    back_button.pressed.connect(_on_back_pressed)
    _populate_hero_grid()
    _on_hero_button_pressed(selected_hero)

func _populate_hero_grid() -> void:
    for child in hero_grid.get_children():
        child.queue_free()
    for hero_id in HERO_DATA.keys():
        var data: Dictionary = HERO_DATA[hero_id]
        var btn := Button.new()
        btn.text = "%s\n%s" % [data["name"], data["role"]]
        btn.custom_minimum_size = Vector2(190, 92)
        btn.pressed.connect(_on_hero_button_pressed.bind(hero_id))
        hero_grid.add_child(btn)

func _on_hero_button_pressed(hero_id: String) -> void:
    selected_hero = hero_id
    var data: Dictionary = HERO_DATA[hero_id]
    hero_name_label.text = data["name"]
    hero_desc_label.text = data["desc"]
    hero_role_label.text = "Role: %s | Difficulty: %d" % [data["role"], data["difficulty"]]
    for child in hero_grid.get_children():
        if child is Button:
            child.modulate = Color(1.0, 0.82, 0.28, 1.0) if child.text.begins_with(data["name"]) else Color.WHITE

func _on_confirm_pressed() -> void:
    if has_node("/root/GameManager"):
        GameManager.set_selected_hero_class(selected_hero)
    hero_selected.emit(selected_hero)
    game_started.emit()
    GameManager.start_game()
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
