extends PlayerState

@export var _character_pivot : Node3D;
@export var _camera_pivot : Node3D;
# How fast the player moves in meters per second.
@export var move_speed : float = 14.0;
@export var running_anim_name : String;


func physics_update(_delta: float) -> void:
	# Horizontal movement
	var raw_input : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back");
	var movement : Vector3 = Vector3(raw_input.x, 0.0, raw_input.y);
	# Correct rotation
	movement = movement.rotated(Vector3.UP, _camera_pivot.rotation.y);
	movement *= move_speed;
	player.velocity = movement;
	# While we're here, rotate the character model
	if movement.length() > 0.2:
		_character_pivot.look_at(player.global_transform.origin + movement);
	
	player.move_and_slide();
	
	#TODO: switch which animation we play based on how fast we're moving
	if movement.length() < 0.5:
		pass; #pose_anim.play(walking_anim_name);
	else:
		pass; #pose_anim.play(running_anim_name);
	
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
	elif (Input.is_action_just_pressed("special_attack")):
		finished.emit(SPECIAL_ATK);
