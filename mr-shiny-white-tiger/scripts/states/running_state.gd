extends PlayerState

@export var _character_pivot : Node3D;
@export var _camera_pivot : Node3D;
# How fast the player moves in meters per second.
@export var move_speed : float = 14.0;
@export var walking_anim_name : StringName;
@export var running_anim_name : StringName;


func physics_update(_delta: float) -> void:
	# Horizontal movement
	var raw_input : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back");
	var movement : Vector3 = Vector3(raw_input.x, 0.0, raw_input.y);
	# Correct rotation
	movement = movement.rotated(Vector3.UP, _camera_pivot.rotation.y);
	movement *= move_speed;
	if special_mode_on:
		movement *= 2;
	player.velocity = movement;
	# While we're here, rotate the character model
	if movement.length() > 0.2:
		_character_pivot.look_at(player.global_transform.origin + movement);
	
	player.move_and_slide();
	
	# Switch which animation we play based on how fast we're moving
	if raw_input.length() < 0.45:
		if pose_anim.current_animation != walking_anim_name:
			#print("switching to walk anim");
			pose_anim.play(walking_anim_name, 0.25);
	else:
		if pose_anim.current_animation != running_anim_name:
			#print("switching to run anim");
			pose_anim.play(running_anim_name, 0.25);
	
	# State transitions
	if !player.is_on_floor():
		finished.emit(AIR, {"jumping": false})
	elif Input.is_action_just_pressed("jump"):
		finished.emit(AIR, {"jumping": true});
	elif raw_input == Vector2.ZERO:
		finished.emit(IDLE);
	elif (Input.is_action_just_pressed("grapple")):
		finished.emit(GRAPPLING);
	elif (Input.is_action_just_pressed("light_attack")):
		finished.emit(ATTACKING, {"type": "light"});
	elif (Input.is_action_just_pressed("heavy_attack")):
		finished.emit(ATTACKING, {"type": "heavy"});
	#elif (Input.is_action_just_pressed("special_attack")):
		#finished.emit(SPECIAL_ATK);
