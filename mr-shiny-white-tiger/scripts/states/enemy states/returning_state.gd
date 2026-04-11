extends EnemyState

@export var _character_pivot : Node3D;
@export var walking_anim_name : StringName;
@export var player_detection_raycast : RayCast3D;

const THRESHOLD : float = 0.2;

func enter(_previous_state_path: String, _data := {}) -> void:
	if pose_anim.current_animation != walking_anim_name:
		pose_anim.play(walking_anim_name, 0.25);
	player_detection_raycast.enabled = true;

func physics_update(_delta: float) -> void:
	var vec_to_position : Vector3 = this_enemy.starting_transform.origin - this_enemy.global_position;
	var move_vec : Vector3 = vec_to_position.normalized() * this_enemy.return_speed;
	move_vec.y = 0;
	this_enemy.velocity = move_vec;
	# Rotate character model
	if move_vec.length() > 0.2:
		_character_pivot.look_at(this_enemy.global_position + move_vec);
	
	this_enemy.move_and_slide();
	
	if vec_to_position.length() <= THRESHOLD:
		this_enemy.global_transform = this_enemy.starting_transform;
		_character_pivot.global_basis = this_enemy.starting_transform.basis;
		finished.emit(READY);
	
	player_detection_raycast.look_at(Global.player.global_position + 1 * Vector3.UP);
	if (player_detection_raycast.get_collider() as Player) != null:
		if (-player_detection_raycast.global_basis.z).angle_to(-_character_pivot.global_basis.z) < this_enemy.fov:
			finished.emit(CHASING);
			
	if !this_enemy.is_on_floor():
		finished.emit(AIR);

func exit() -> void:
	player_detection_raycast.enabled = true;
