extends Node3D

@export_range(0.0, 1.0) var camera_sensitivity_h : float = 0.01;
@export_range(0.0, 1.0) var camera_sensitivity_v : float = 0.01;
@export var tilt_limit_up : float = 65;
@export var tilt_limit_down : float = -65;
@export var invert_camera_h : bool = false;
@export var invert_camera_v : bool = true;
@onready var invert_camera_h_multiplier : int = -1 if invert_camera_h else 1;
@onready var invert_camera_v_multiplier : int = -1 if invert_camera_v else 1;


func _ready() -> void:
	# Camera setup
	tilt_limit_up = deg_to_rad(tilt_limit_up);
	tilt_limit_down = deg_to_rad(tilt_limit_down);
#endfunc


# Handles camera movement
func _process(_delta: float) -> void:
	var input_dir : Vector2 = Input.get_vector("camera_left", "camera_right", "camera_down", "camera_up");
	# Vertical rotation (around x-axis)
	rotation.x += input_dir.y * camera_sensitivity_v * invert_camera_v_multiplier;
	# Prevent the camera from rotating too far up or down.
	rotation.x = clampf(rotation.x, tilt_limit_down, tilt_limit_up);
	# Horizonal rotation (around y-axis)
	rotation.y += -input_dir.x * camera_sensitivity_h * invert_camera_h_multiplier;
#endfunc
