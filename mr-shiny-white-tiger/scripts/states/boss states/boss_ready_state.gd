extends EnemyState

@export var idle_anim_name: StringName;
@export var landing_anim_name: StringName;
@export var boss_health_bar: TextureProgressBar;
#@export var player_detection_raycast : RayCast3D;
#@export var _character_pivot : Node3D;

func _ready() -> void:
	await super._ready();
	if boss_health_bar != null:
		boss_health_bar.visible = false;
	#player_detection_raycast.target_position = Vector3(0, 0, -this_enemy.detection_range);


func enter(_previous_state_path: String, _data := {}) -> void:
	this_enemy.velocity.x = 0.0;
	this_enemy.velocity.z = 0.0;
	pose_anim.animation_finished.connect(_on_animation_finished);
	pose_anim.play(idle_anim_name, 0.2);
	#player_detection_raycast.enabled = true;


func physics_update(_delta: float) -> void:
	#player_detection_raycast.look_at(Global.player.global_position + 1 * Vector3.UP);
	#if (player_detection_raycast.get_collider() as Player) != null:
		#if (-player_detection_raycast.global_basis.z).angle_to(-_character_pivot.global_basis.z) < this_enemy.fov:
			#finished.emit(CHASING);
	var player_in_range : bool = ((Vector3(Global.player.global_position.x, this_enemy.global_position.y, Global.player.global_position.z) - this_enemy.global_position).length_squared() <= this_enemy.atk_range ** 2);
	if player_in_range:
		finished.emit(CHASING);
	
	# cheat code
	if Input.is_key_pressed(KEY_ALT) && Input.is_key_pressed(KEY_B):
		finished.emit(DEATH);

func _on_animation_finished(_anim_name: StringName):
	pose_anim.play(idle_anim_name);


func exit() -> void:
	pose_anim.animation_finished.disconnect(_on_animation_finished);
	if boss_health_bar != null:
		boss_health_bar.visible = true;
	#player_detection_raycast.enabled = false;
