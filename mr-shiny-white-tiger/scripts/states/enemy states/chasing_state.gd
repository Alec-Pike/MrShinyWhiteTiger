extends EnemyState

@export var _character_pivot : Node3D;
@export var running_anim_name : StringName;

var chase_timer : float = 0;


func enter(_previous_state_path: String, _data := {}) -> void:
	if pose_anim.current_animation != running_anim_name:
		pose_anim.play(running_anim_name, 0.25);
	

func physics_update(_delta: float) -> void:
	var vec_to_player : Vector3 = Global.player.global_position - this_enemy.global_position;
	var move_vec : Vector3 = vec_to_player.normalized() * this_enemy.chase_speed;
	move_vec.y = 0;
	this_enemy.velocity = move_vec;
	# Rotate character model
	if move_vec.length() > 0.2:
		_character_pivot.look_at(this_enemy.global_transform.origin + move_vec);
	
	this_enemy.move_and_slide();
	
	if vec_to_player.length() <= this_enemy.atk_range:
		finished.emit(CIRCLING);
	
	chase_timer += _delta;
	if chase_timer >= this_enemy.chase_time_out_threshold:
		chase_timer = 0.0;
		finished.emit(RETURNING);
		
	if !this_enemy.is_on_floor():
		finished.emit(AIR);
