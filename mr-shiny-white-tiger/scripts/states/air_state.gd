extends PlayerState

@export_category("References")
@export var _character_pivot : Node3D;
@export var _camera_pivot : Node3D;
@export var landing_check_raycast : RayCast3D;
@export_category("Stats")
@export var jump_strength : float = 50.0;
@export var air_move_speed : float = 14.0;
# The downward acceleration when in the air, in meters per second squared.
@export var gravity : float = 75.0;
# Extra parameters to make the physics feel more "gamey"
@export var fall_multiplier : float = 2.5;
@export var low_jump_multiplier : float = 2.0;
@export var coyote_time : float = 0.3;
var remaining_coyote_time : float = coyote_time;

@export_category("Animations")
@export var jump_anim_name : String;
@export var falling_anim_name : String;
@export var landing_anim_name: StringName;


func enter(_previous_state_path: String, data := {}) -> void:
	if data.has("jumping") && data["jumping"]:
		# 1. Immediate Physics (Responsiveness)
		player.velocity.y = jump_strength;
		print("Jumped");
		# 2. Immediate Animation (Trimmed Windup)
		# Note: Set blend_time to 0.1 in AnimationPlayer for smoothness
		pose_anim.play(jump_anim_name, 0.1);
		
		remaining_coyote_time = 0;
	else:
		# We just walked off a ledge
		pose_anim.play(falling_anim_name, 0.2);
		remaining_coyote_time = coyote_time;
	
	pose_anim.animation_finished.connect(_on_animation_finished);


func physics_update(delta: float) -> void:
	# Horizontal movement
	var raw_input : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back");
	var move_direction : Vector3 = Vector3(raw_input.x, 0.0, raw_input.y);
	# Correct rotation
	move_direction = move_direction.rotated(Vector3.UP, _camera_pivot.rotation.y);
	move_direction = move_direction.normalized() * air_move_speed;
	player.velocity = move_direction + (player.velocity.y * Vector3.UP);
	# While we're here, rotate the character model
	if move_direction != Vector3.ZERO:
		_character_pivot.look_at(player.global_transform.origin + move_direction);
	
	# Vertical movement
	remaining_coyote_time -= delta;
	if remaining_coyote_time > 0 && Input.is_action_just_pressed("jump"):
		self.enter(AIR, {"jumping": true});
	
	# Always add gravity
	player.velocity.y -= gravity * delta;
	# Now add some "game feel"
	if player.velocity.y < 0: # If we're falling down,
		player.velocity.y -= gravity * (fall_multiplier - 1) * delta; # Fall a little faster
	elif player.velocity.y > 0 && !Input.is_action_pressed("jump"): # If we did a small jump (not holding the button),
		player.velocity.y -= gravity * (low_jump_multiplier - 1) * delta; # Come down sooner
	
	player.move_and_slide();
	
	# Animation check
	landing_check_raycast.force_raycast_update();
	if (player.velocity.y <= 0 && landing_check_raycast.is_colliding()) || player.is_on_floor():
		if pose_anim.current_animation != landing_anim_name:
			print("signaled landing anim")
			pose_anim.play(landing_anim_name, 0.1);
	
	# State Transitions
	if pose_anim.current_animation == landing_anim_name:
		if (Input.is_action_just_pressed("jump")):
			finished.emit(AIR, {"jumping": true});
	if player.is_on_floor():
		if raw_input != Vector2.ZERO:
			finished.emit(RUNNING);
	elif (Input.is_action_just_pressed("grapple")):
		finished.emit(GRAPPLING);
	elif (Input.is_action_just_pressed("light_attack")):
		finished.emit(ATTACKING, {"type": "light"});
	elif (Input.is_action_just_pressed("heavy_attack")):
		finished.emit(ATTACKING, {"type": "heavy"});


func _on_animation_finished(_anim_name: StringName):
	print("anim that ended: " + _anim_name)
	if _anim_name == landing_anim_name:
		finished.emit(IDLE);
	else:
		pose_anim.play(falling_anim_name, 0.2);


func exit() -> void:
	pose_anim.animation_finished.disconnect(_on_animation_finished);
