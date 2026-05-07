extends EnemyState

@export var _character_pivot : Node3D;
@export var floor_detector : RayCast3D;
@export var running_anim_name : StringName;

@onready var circling_direction = [1, -1].pick_random();
var circle_timer : float = 0;
var circle_time_threshold : float;

const HYSTERESIS : float = 5.0;


func enter(_previous_state_path: String, _data := {}) -> void:
	circling_direction = [1, -1].pick_random();
	circle_time_threshold = randf_range(this_enemy.min_circle_time, this_enemy.max_circle_time);
	if pose_anim.current_animation != running_anim_name:
		pose_anim.play(running_anim_name, 0.25);
	floor_detector.enabled = true;
	

func physics_update(_delta: float) -> void:
	var vec_to_player : Vector3 = Global.player.global_position - this_enemy.global_position;
	var move_vec : Vector3 = vec_to_player.normalized() * (this_enemy.circle_speed);
	move_vec.y = 0;
	const TURN_ANGLE : float = deg_to_rad(89);
	move_vec = move_vec.rotated(Vector3.UP, TURN_ANGLE * circling_direction);
	this_enemy.velocity = move_vec;
	# Rotate character model
	if move_vec.length() > 0.2:
		_character_pivot.look_at(this_enemy.global_transform.origin + move_vec);
	this_enemy.move_and_slide();
	
	if vec_to_player.length() > this_enemy.atk_range + HYSTERESIS:
		finished.emit(CHASING);
	
	circle_timer += _delta;
	if circle_timer >= circle_time_threshold:
		circle_timer = 0;
		finished.emit(ATTACKING);
	
	if this_enemy.is_on_wall():
		circling_direction *= -1;
	else:
		floor_detector.force_raycast_update();
		if !floor_detector.is_colliding():
			circling_direction *= -1;


func exit() -> void:
	floor_detector.enabled = false;
