extends CanvasLayer

@onready var title_label: Label = $ColorRect/VBoxContainer/TitleLabel
@onready var detail_label: Label = $ColorRect/VBoxContainer/DetailLabel
@onready var restart_button: Button = $ColorRect/VBoxContainer/RestartButton
@onready var menu_button: Button = $ColorRect/VBoxContainer/MenuButton

func _ready() -> void:
    hide()
    process_mode = Node.PROCESS_MODE_ALWAYS
    GameManager.game_ended.connect(_on_game_ended)
    restart_button.pressed.connect(_on_restart_pressed)
    menu_button.pressed.connect(_on_menu_pressed)

func _on_game_ended(winner_team: GameManager.Team) -> void:
    show()
    title_label.text = "VICTORY" if winner_team == GameManager.player_team else "DEFEAT"
    detail_label.text = "Final score  Blue %d : Red %d\nTime %s" % [GameManager.team_scores["blue"], GameManager.team_scores["red"], GameManager.get_formatted_time()]

func _on_restart_pressed() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
