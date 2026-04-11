extends EnemyState

@export_category("References")
@export var _character_pivot : Node3D;
@export var landing_check_raycast : RayCast3D;
@export_category("Animations")
@export var falling_anim_name : StringName;
@export var landing_anim_name: StringName;

var prev_state : String = "";

func enter(_previous_state_path: String, _data := {}) -> void:
	prev_state = _previous_state_path; # could be CHASING, RETURNING, or GETTING_HIT
	pose_anim.play(falling_anim_name, 0.2);
	pose_anim.animation_finished.connect(_on_animation_finished);


func physics_update(delta: float) -> void:
	# Horizontal movement
	var target : Vector3 = this_enemy.starting_transform.origin if prev_state == RETURNING else Global.player.global_position;
	var vec_to_target : Vector3 = target - this_enemy.global_position;
	var move_vec : Vector3 = Vector3(vec_to_target.x, 0.0, vec_to_target.z);
	move_vec = move_vec.normalized() * this_enemy.air_speed;
	this_enemy.velocity = move_vec + (this_enemy.velocity.y * Vector3.UP);
	# While we're here, rotate the character model
	if move_vec != Vector3.ZERO:
		_character_pivot.look_at(this_enemy.global_position + move_vec);	
	# Always add gravity
	this_enemy.velocity.y -= this_enemy.gravity * delta;
	
	this_enemy.move_and_slide();
	
	# Animation check
	landing_check_raycast.force_raycast_update();
	if (this_enemy.velocity.y <= 0 && landing_check_raycast.is_colliding()) || this_enemy.is_on_floor():
		if pose_anim.current_animation != landing_anim_name:
			print("Enemy: signaled landing anim")
			pose_anim.play(landing_anim_name, 0.1);
	
	# State Transitions
	if this_enemy.is_on_floor():
		if prev_state == GETTING_HIT:
			finished.emit(CHASING);
		else:
			finished.emit(prev_state);


func _on_animation_finished(_anim_name: StringName):
	print("Enemy: anim that ended: " + _anim_name)
	if _anim_name == landing_anim_name:
		if prev_state == GETTING_HIT:
			finished.emit(CHASING);
		else:
			finished.emit(prev_state);
	else:
		pose_anim.play(falling_anim_name, 0.2);


func exit() -> void:
	pose_anim.animation_finished.disconnect(_on_animation_finished);
