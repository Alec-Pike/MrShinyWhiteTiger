extends Node

var player : Player;
var rand = RandomNumberGenerator.new();

var invert_camera_h : bool = false;
var invert_camera_v : bool = true;

signal increase_style(points: int);

func game_init() -> void:
	player.is_dead.connect(_on_player_death);


func _on_player_death() -> void:
	get_tree().change_scene_to_file("res://_scenes/main_menu.tscn");
