extends Control

@export var retry_button: Button;
@export var exit_button: Button;

@export var style_score: Label;
@export var timer_bonus: Label;
@export var final_score: Label;

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed);
	exit_button.pressed.connect(_on_exit_pressed);
	
	style_score.text = "STYLE SCORE: %d" % Global.style_score;
	timer_bonus.text = "TIME BONUS:  %d" % Global.time_bonus;
	final_score.text = "FINAL SCORE: %d" % Global.total_score;
	
	retry_button.grab_focus.call_deferred();

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://_scenes/level.tscn");

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://_scenes/main_menu.tscn");
