extends CharacterBody3D

# Movement stuff
@export_group("Movement")
@onready var _character_pivot : Node3D = $CharacterPivot;
# How fast the player moves in meters per second.
@export var move_speed : float = 14.0;
@export var jump_strength : float = 50.0;
# The downward acceleration when in the air, in meters per second squared.
@export var gravity : float = 75.0;
# Extra parameters to make the physics feel more "gamey"
@export var fall_multiplier : float = 2.5;
@export var low_jump_multiplier : float = 2.0;
@export var num_coyote_frames : int = 10;
var remaining_coyote_frames : int = num_coyote_frames;

# Camera stuff
@export_group("Camera")
@onready var _camera_pivot : Node3D = $CameraPivot;
@export_range(0.0, 1.0) var camera_sensitivity_h : float = 0.01;
@export_range(0.0, 1.0) var camera_sensitivity_v : float = 0.01;
@export var tilt_limit_up : float = 65;
@export var tilt_limit_down : float = -65;
@export var invert_camera_h : bool = false;
@export var invert_camera_v : bool = true;
var invert_camera_h_multiplier : int;
var invert_camera_v_multiplier : int;


func _ready() -> void:
	# Camera setup
	invert_camera_h_multiplier = -1 if invert_camera_h else 1;
	invert_camera_v_multiplier = -1 if invert_camera_v else 1;
	tilt_limit_up = deg_to_rad(tilt_limit_up);
	tilt_limit_down = deg_to_rad(tilt_limit_down);
#endfunc

# Handles all movement
func _physics_process(delta: float) -> void:
		# Horizontal movement
	var raw_input : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back");
	var move_direction : Vector3 = Vector3(raw_input.x, 0.0, raw_input.y);
	# Correct rotation
	move_direction = move_direction.rotated(Vector3.UP, _camera_pivot.rotation.y);
	move_direction = move_direction.normalized() * move_speed;
	velocity.x = move_direction.x;
	velocity.z = move_direction.z;
	# While we're here, rotate the character model
	if move_direction != Vector3.ZERO:
		_character_pivot.look_at(global_transform.origin + move_direction);
	
	# Vertical movement
	if remaining_coyote_frames > 0 && Input.is_action_just_pressed("jump"):
		velocity.y += jump_strength;
	if is_on_floor():
		remaining_coyote_frames = num_coyote_frames;
		#TODO: add fall damage
		if !Input.is_action_just_pressed("jump"):
			velocity.y = 0.0;
	else: # Must be in the air
		remaining_coyote_frames -= 1;
		# Always add gravity
		velocity.y -= gravity * delta;
		# Now add some "game feel"
		if velocity.y < 0: # If we're falling,
			velocity.y -= gravity * (fall_multiplier - 1) * delta; # Fall a little faster
		elif velocity.y > 0 && !Input.is_action_pressed("jump"): # If we did a small jump,
			velocity.y -= gravity * (low_jump_multiplier - 1) * delta; # Come down sooner
	
	# Apply
	move_and_slide();
#endfunc

# Handles camera movement
func _process(_delta: float) -> void:
	var input_dir : Vector2 = Input.get_vector("camera_left", "camera_right", "camera_down", "camera_up");
	# Vertical rotation (around x-axis)
	_camera_pivot.rotation.x += input_dir.y * camera_sensitivity_v * invert_camera_v_multiplier;
	# Prevent the camera from rotating too far up or down.
	_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, tilt_limit_down, tilt_limit_up);
	# Horizonal rotation (around y-axis)
	_camera_pivot.rotation.y += -input_dir.x * camera_sensitivity_h * invert_camera_h_multiplier;
#endfunc
