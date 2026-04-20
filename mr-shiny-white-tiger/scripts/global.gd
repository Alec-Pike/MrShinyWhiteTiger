extends Node

var player : Player;
var rand = RandomNumberGenerator.new();

func _ready() -> void:
	player.is_dead.connect(_on_player_death);


func _on_player_death() -> void:
	get_tree().quit();
