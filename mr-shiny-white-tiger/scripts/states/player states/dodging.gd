extends PlayerState

@export var dodge_anim_name : StringName;
@export var _camera_pivot : Node3D;
@export var move_speed : float;
var prev_state : String;

func enter(_previous_state_path: String, _data := {}) -> void:
	prev_state = _previous_state_path;
	pose_anim.animation_finished.connect(_on_animation_finished);
	pose_anim.play(dodge_anim_name, 0.2);
	
	# Calculate horizontal movement once at the start
	var raw_input : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back");
	if prev_state == IDLE:
		raw_input = Vector2(0.0, 1.0); # Defaults to backwards
	var movement : Vector3 = Vector3(raw_input.x, 0.0, raw_input.y);
	movement = movement.normalized();
	# Correct rotation
	movement = movement.rotated(Vector3.UP, _camera_pivot.rotation.y);
	movement *= move_speed;
	if special_mode_on:
		movement *= 2;
	player.velocity = movement;


func physics_update(_delta: float) -> void:
	player.move_and_slide();


func _on_animation_finished(_anim : StringName):
	print("Detected end of dodge animation");
	finished.emit(prev_state);


func exit() -> void:
	pose_anim.animation_finished.disconnect(_on_animation_finished);
