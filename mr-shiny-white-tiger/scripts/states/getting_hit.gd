extends State

@export var character_pivot : Node3D;
@export var gravity : float;
@export var knockback_scale : float = 1.0;
@export_category("Animation")
@export var hit_small_anim_name : StringName;
@export var hit_large_anim_name : StringName;
@export var death_anim_name : StringName;
@export var recovery_anim_name : StringName;
@export var pose_anim : AnimationPlayer;
@export var face_anim : AnimationPlayer;

var character : CharacterBody3D;
#TODO: some sort of reference/access to the character's HP

func _ready() -> void:
	character = owner as CharacterBody3D;

func enter(_previous_state_path: String, _data := {}) -> void:
	#TODO: reduce HP
	# play animation based on kbk or on dmg?
	# calculate and set knockback velocity
	# connect on_animation_finished signal?
	pass


func physics_update(_delta: float) -> void:
	# TODO: update velocity in kbk arc
	# move_and_slide();
	pass
