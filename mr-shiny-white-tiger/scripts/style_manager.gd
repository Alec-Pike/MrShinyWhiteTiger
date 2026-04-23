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

signal set_special_mode(setting : bool);
var special_mode_on : bool = false;
const SPECIAL_MODE_TIME : float = 30.0;
var special_mode_timer : float = 0.0;
const RATE_SP_DECREASE : float = METER_FILL_MAX / SPECIAL_MODE_TIME;

var score_display_original_scale : Vector2;
var score_display_pop_scale : Vector2;

func _ready() -> void:
	atk_state.atk_successful.connect(handle_atk);
	style_score_display.text = "0";
	sp_atk_meter_display.value = 0.0;
	sp_atk_meter_display.min_value = 0;
	sp_atk_meter_display.max_value = METER_FILL_MAX;
	score_display_original_scale = style_score_display.scale;
	score_display_pop_scale = score_display_original_scale * 1.5;


func _input(event: InputEvent) -> void:
	if (sp_atk_meter_fill == METER_FILL_MAX) && (event.is_action_pressed("special_attack")):
		emit_signal("set_special_mode", true);
		print("SPECIAL MODE ACTIVATED");
		special_mode_timer = SPECIAL_MODE_TIME;
		sp_atk_meter_fill = 0;
		special_mode_on = true;


func _process(delta: float) -> void:
	for atk in atk_elapsed_times:
		atk_elapsed_times[atk] += delta;
	
	if special_mode_on:
		special_mode_timer -= delta;
		# Have to calculate this way to avoid frame-by-frame rounding errors
		var time_ratio : float = special_mode_timer / SPECIAL_MODE_TIME;
		sp_atk_meter_display.value = time_ratio * METER_FILL_MAX;
		if special_mode_timer <= 0.0:
			print("SPECIAL MODE DEACTIVATED");
			special_mode_on = false;
			sp_atk_meter_display.value = 0.0;
			emit_signal("set_special_mode", false);
	
	# Cheat code: Alt+S to completely fill sp atk meter
	if Input.is_key_pressed(KEY_S) && Input.is_key_pressed(KEY_ALT):
		sp_atk_meter_fill = METER_FILL_MAX;
		sp_atk_meter_display.value = METER_FILL_MAX;


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
	if special_mode_on: points *= 2;
	print("+" + str(points) + " style points");
	# Update special meter
	if !special_mode_on:
		sp_atk_meter_fill += points;
		if sp_atk_meter_fill >= METER_FILL_MAX:
			sp_atk_meter_fill = METER_FILL_MAX;
		sp_atk_meter_display.value = sp_atk_meter_fill;
	# Update total score
	style_score += points;
	style_score_display.text = str(style_score);
	# Animate the score display
	style_score_display.scale = score_display_pop_scale;
	var tween : Tween = create_tween();
	tween.tween_property(style_score_display, "scale", score_display_original_scale, 0.3) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT);
