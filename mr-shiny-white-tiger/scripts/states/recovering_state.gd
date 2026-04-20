extends State

@export var next_state_name : StringName;
@export_category("Animation")
@export var recovery_anim_name : StringName;
@export var pose_anim : AnimationPlayer;
@export var face_anim : AnimationPlayer;

func enter(_previous_state_path: String, _data := {}) -> void:
	pose_anim.animation_finished.connect(_on_animation_finished);
	pose_anim.play(recovery_anim_name);


func _on_animation_finished(_anim_name: StringName):
	finished.emit(next_state_name);


func exit() -> void:
	pose_anim.animation_finished.disconnect(_on_animation_finished);
