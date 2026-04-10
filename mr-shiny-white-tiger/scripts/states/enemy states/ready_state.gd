extends EnemyState

@export var idle_anim_name: StringName;
@export var landing_anim_name: StringName;
@export var player_detection_raycast : RayCast3D;

func _ready() -> void:
	await super._ready();
	player_detection_raycast.target_position = Vector3(0, 0, -this_enemy.detection_range);


func enter(_previous_state_path: String, _data := {}) -> void:
	this_enemy.velocity.x = 0.0;
	this_enemy.velocity.z = 0.0;
	pose_anim.animation_finished.connect(_on_animation_finished);
	#if _previous_state_path != AIR:
	pose_anim.play(idle_anim_name, 0.2);


func physics_update(_delta: float) -> void:
	player_detection_raycast.look_at(Global.player.global_transform.origin);
	if player_detection_raycast.is_colliding():
		if (-player_detection_raycast.global_basis.z).angle_to(-this_enemy.global_basis.z) < this_enemy.fov:
			finished.emit(CHASING);

func _on_animation_finished(_anim_name: StringName):
	pose_anim.play(idle_anim_name);


func exit() -> void:
	pose_anim.animation_finished.disconnect(_on_animation_finished);
