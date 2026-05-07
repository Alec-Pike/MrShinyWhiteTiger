extends State

@export var character_pivot : Node3D;
@export var gravity : float;
@export var knockback_scale : float = 1.0;
@export var big_hit_threshold : int = 10;
@export var next_state_name : StringName;
@export var i_frame_seconds : float = 0.0;
@export_category("Animation")
@export var hit_small_anim_name : StringName;
@export var hit_large_anim_name : StringName;
#@export var death_anim_name : StringName;
#@export var recovery_anim_name : StringName;
@export var pose_anim : AnimationPlayer;
@export var face_anim : AnimationPlayer;
@export_category("SFX")
@export var audio_player : AudioStreamPlayer;
@export var hit_sound : AudioStream;

var character : CharacterBody3D;
var is_big_hit : bool = false;
var anim_is_done : bool = false;
var i_frame_timer : float = 0.0;

const TERMINAL_VELOCITY : float = -7;


func _ready() -> void:
	character = owner as CharacterBody3D;
	assert(("hp" in character), "Owner must have an 'hp' attribute");


func enter(_previous_state_path: String, _data := {}) -> void:
	character.hp -= _data.damage;
	print(character.name, " has ", character.hp, "hp remaining")
	# Handle death if necessary
	if character.hp <= 0:
		finished.emit("Death");
		return;
	
	anim_is_done = false;
	
	pose_anim.animation_finished.connect(_on_animation_finished);
	
	is_big_hit = (_data.damage >= big_hit_threshold);
	if is_big_hit:
		pose_anim.play(hit_large_anim_name);
	else:
		pose_anim.play(hit_small_anim_name);
	# calculate and set knockback velocity
	character_pivot.look_at(_data.attacker_position);
	character.velocity = character_pivot.global_basis * _data.knockback * -1 * knockback_scale;
	character.velocity.y *= -1;
	
	audio_player.stream = hit_sound;
	audio_player.play();


func update(_delta: float) -> void:
	i_frame_timer += _delta;


func is_invulnerable() -> bool:
	return (i_frame_timer < i_frame_seconds);


func physics_update(_delta: float) -> void:
	character.velocity.y -= gravity * _delta;
	character.move_and_slide();
	
	if character.global_position.y <= -5 || (character.velocity.y <= TERMINAL_VELOCITY && character.is_on_floor()):
		finished.emit("Death");
		return;
	
	if anim_is_done:
		if is_big_hit:
			if character.is_on_floor():
				finished.emit("Recovering");
		else:
			if !character.is_on_floor():
				finished.emit("Air");
			else:
				finished.emit(next_state_name);


func _on_animation_finished(_anim_name: StringName):
	anim_is_done = true;


func exit() -> void:
	pose_anim.animation_finished.disconnect(_on_animation_finished);
	character.velocity = Vector3.ZERO;
	i_frame_timer = 0.0;
