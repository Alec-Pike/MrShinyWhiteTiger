extends Node

@export_category("References")
@export var sp_atk_meter_display : TextureProgressBar;
@export var style_score_display : Label;
@export var atk_state : State;

var style_score : int = 0;
var sp_atk_meter_fill : int = 0;
var atk_elapsed_times : Dictionary[AttackResource, float];

const METER_FILL_MAX : int = 1000;
const STYLISH_TIME_THRESHOLD : float = 25.0;
const EXTRA_POINTS_PER_SECOND : float = 0.1;
const UNSTYLISH_MULTIPLIER : float = 0.5;

func _ready() -> void:
	atk_state.atk_successful.connect(handle_atk);
	style_score_display.text = "0";
	sp_atk_meter_display.value = 0.0;
	sp_atk_meter_display.min_value = 0;
	sp_atk_meter_display.max_value = METER_FILL_MAX;


func _process(delta: float) -> void:
	for atk in atk_elapsed_times:
		atk_elapsed_times[atk] += delta;


func handle_atk(atk: AttackResource):
	if atk not in atk_elapsed_times:
		atk_elapsed_times[atk] = STYLISH_TIME_THRESHOLD;
	print(atk.animation_name + " used for the first time in " + str(atk_elapsed_times[atk]) + " secs");
	if atk_elapsed_times[atk] >= STYLISH_TIME_THRESHOLD:
		increase_style(floori(atk.style_points + (atk_elapsed_times[atk] * EXTRA_POINTS_PER_SECOND)));
	else:
		increase_style(floori(atk.style_points * UNSTYLISH_MULTIPLIER));
	atk_elapsed_times[atk] = 0;


func increase_style(points : int):
	print("+" + str(points) + " style points");
	style_score += points;
	sp_atk_meter_fill += points;
	if sp_atk_meter_fill >= METER_FILL_MAX:
		sp_atk_meter_fill = METER_FILL_MAX;
	style_score_display.text = str(style_score);
	#TODO: animate the score display
	sp_atk_meter_display.value = sp_atk_meter_fill;
