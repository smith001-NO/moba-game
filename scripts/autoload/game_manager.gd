extends Node

enum GameState { MENU, HERO_SELECT, PLAYING, PAUSED, GAME_OVER }
enum Team { BLUE, RED, NEUTRAL }

var current_state: GameState = GameState.MENU
var team_scores: Dictionary = {"blue": 0, "red": 0}
var game_time: float = 0.0
var player_team: Team = Team.BLUE
var winner_team: Team = Team.NEUTRAL
var selected_hero_class: String = "arc_knight"

signal state_changed(new_state: GameState)
signal game_started
signal game_ended(winner: Team)
signal score_updated(team: Team, score: int)

func _process(delta: float) -> void:
    if current_state == GameState.PLAYING:
        game_time += delta

func start_game() -> void:
    if has_node("/root/TeamManager"):
        TeamManager.clear_all()
    current_state = GameState.PLAYING
    winner_team = Team.NEUTRAL
    game_time = 0.0
    team_scores = {"blue": 0, "red": 0}
    state_changed.emit(GameState.PLAYING)
    game_started.emit()

func pause_game() -> void:
    if current_state != GameState.PLAYING:
        return
    current_state = GameState.PAUSED
    get_tree().paused = true
    state_changed.emit(GameState.PAUSED)

func resume_game() -> void:
    if current_state != GameState.PAUSED:
        return
    current_state = GameState.PLAYING
    get_tree().paused = false
    state_changed.emit(GameState.PLAYING)

func end_game(winner: Team) -> void:
    if current_state == GameState.GAME_OVER:
        return
    current_state = GameState.GAME_OVER
    winner_team = winner
    state_changed.emit(GameState.GAME_OVER)
    game_ended.emit(winner)

func add_score(team: Team, points: int) -> void:
    if team == Team.NEUTRAL:
        return
    var team_key: String = "blue"
    if team != Team.BLUE:
        team_key = "red"
    team_scores[team_key] = int(team_scores.get(team_key, 0)) + points
    score_updated.emit(team, team_scores[team_key])

func get_formatted_time() -> String:
    var total = int(game_time)
    var minutes = total / 60
    var seconds = total % 60
    return "%02d:%02d" % [minutes, seconds]

func team_name(team: Team) -> String:
    match team:
        Team.BLUE:
            return "Blue"
        Team.RED:
            return "Red"
        _:
            return "Neutral"

func set_selected_hero_class(hero_class: String) -> void:
    selected_hero_class = hero_class

func get_selected_hero_class() -> String:
    return selected_hero_class

