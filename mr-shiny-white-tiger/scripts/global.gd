extends Node

var player : Player;
var game_timer: Timer;
var style_manager: Node;
var rand = RandomNumberGenerator.new();

var invert_camera_h : bool = false;
var invert_camera_v : bool = true;

var style_score: int = 0;
var time_bonus: int = 0;
var total_score: int = 0;
const POINTS_PER_SEC_REMAINING: int = 10;

signal increase_style(points: int);

func game_init() -> void:
	player.is_dead.connect(_on_player_death);

func _on_player_death() -> void:
	get_tree().change_scene_to_file("res://_scenes/lose_screen.tscn");

func stop_timer() -> void:
	game_timer.paused = true;

func victory() -> void:
	style_score = style_manager.style_score;
	time_bonus = ceili(game_timer.time_left) * POINTS_PER_SEC_REMAINING;
	total_score = style_score + time_bonus;
	print("Style: %d | Time bonus: %d | Total: %d" % [style_score, time_bonus, total_score])
	get_tree().change_scene_to_file("res://_scenes/win_screen.tscn");
