extends PlayerState

@export var idle_anim_name: StringName;
@export var landing_anim_name: StringName;
#@export var gravity : float = 75.0;

func enter(_previous_state_path: String, _data := {}) -> void:
	player.velocity.x = 0.0;
	player.velocity.z = 0.0;
	pose_anim.animation_finished.connect(_on_animation_finished);
	#if _previous_state_path != AIR:
	pose_anim.play(idle_anim_name, 0.2);



func physics_update(_delta: float) -> void:
	#player.velocity.y -= gravity * _delta
	#player.move_and_slide();
#
	## State transitions
	#if !player.is_on_floor():
		#finished.emit(AIR, {"jumping": false});
	#el
	if Input.is_action_just_pressed("jump"):
		finished.emit(AIR, {"jumping": true});
	elif (
	Input.is_action_pressed("move_forward") ||
	Input.is_action_pressed("move_left") ||
	Input.is_action_pressed("move_right") ||
	Input.is_action_pressed("move_back")
	):
		finished.emit(RUNNING);
	elif (Input.is_action_just_pressed("grapple")):
		finished.emit(GRAPPLING);
	elif (Input.is_action_just_pressed("light_attack")):
		finished.emit(ATTACKING, {"type": "light"});
	elif (Input.is_action_just_pressed("heavy_attack")):
		finished.emit(ATTACKING, {"type": "heavy"});
	#elif (Input.is_action_just_pressed("special_attack")):
		#finished.emit(SPECIAL_ATK);


func _on_animation_finished(_anim_name: StringName):
	pose_anim.play(idle_anim_name);


func exit() -> void:
	pose_anim.animation_finished.disconnect(_on_animation_finished);
