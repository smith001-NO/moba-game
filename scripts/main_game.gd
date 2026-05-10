extends Node3D

func _enter_tree() -> void:
    get_tree().paused = false
    GameManager.start_game()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_P:
        if GameManager.current_state == GameManager.GameState.PLAYING:
            GameManager.pause_game()
        elif GameManager.current_state == GameManager.GameState.PAUSED:
            GameManager.resume_game()
