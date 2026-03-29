extends EnemyState

@export var idle_anim_name: StringName;
@export var landing_anim_name: StringName;

func enter(_previous_state_path: String, _data := {}) -> void:
	this_enemy.velocity.x = 0.0;
	this_enemy.velocity.z = 0.0;
	pose_anim.animation_finished.connect(_on_animation_finished);
	#if _previous_state_path != AIR:
	pose_anim.play(idle_anim_name, 0.2);


func physics_update(_delta: float) -> void:
	var vec_to_player : Vector3 = Global.player.global_position - this_enemy.global_position;
	if vec_to_player.length() <= this_enemy.detection_range:
		#TODO: vector math to transition
		pass

func _on_animation_finished(_anim_name: StringName):
	pose_anim.play(idle_anim_name);


func exit() -> void:
	pose_anim.animation_finished.disconnect(_on_animation_finished);
