extends EnemyState

@export_category("References")
@export var character_pivot : Node3D;
@export var hit_shapecast : ShapeCast3D;

var attacks : Array[AttackResource];
var probablilities : Array[float];

var already_hit : bool = false;

var curr_atk : AttackResource = null;
var pending_attacks : Array[AttackResource] = [];


func _ready() -> void:
	await super._ready();
	attacks = this_enemy.attacks_and_probabilities.keys();
	probablilities = this_enemy.attacks_and_probabilities.values();


func enter(_previous_state_path: String, _data := {}) -> void:
	this_enemy.velocity = Vector3.ZERO; # Stop sliding
	hit_shapecast.enabled = false;
	
	# Generate a list of attacks to perform
	for i in randi_range(this_enemy.min_num_atks, this_enemy.max_num_atks):
		pending_attacks.append(attacks[Global.rand.rand_weighted(probablilities)]);
	
	execute_next_attack();
#endfunc

func execute_next_attack():
	# Advance curr_attack
	curr_atk = pending_attacks.pop_back();
	print("curr atk: " + (curr_atk.animation_name if curr_atk else &"Nil"));
	
	# auto-rotating to face the player
	character_pivot.look_at(Vector3(
		Global.player.global_position.x, 
		this_enemy.global_position.y, 
		Global.player.global_position.z
	));
	
	# Set up Hitbox
	hit_shapecast.shape = curr_atk.hit_shape
	hit_shapecast.position.z = -curr_atk.hit_range
	
	already_hit = false;
	# Play Animation
	pose_anim.play(curr_atk.animation_name, -1, curr_atk.speed_factor);
	


func physics_update(_delta: float) -> void:
	# Check for Hit Window
	var anim_time : float = pose_anim.current_animation_position;
	
	if anim_time >= curr_atk.active_time_start && anim_time <= curr_atk.active_time_end:
		hit_shapecast.enabled = true
		hit_shapecast.force_shapecast_update();
		if !already_hit && hit_shapecast.is_colliding():
			Global.player.take_damage(curr_atk.damage, curr_atk.knockback, character_pivot.global_position);
			print("Attack '" + curr_atk.animation_name + "' hit Player");
			if !already_hit: # Only do this once
				already_hit = true;
	else:
		hit_shapecast.enabled = false

	# Check for Transition
	# If the animation is finished
	if anim_time >= curr_atk.transition_ok_time:
		if !pending_attacks.is_empty():
			# --- ADVANCE COMBO ---
			execute_next_attack() # Recursively start the next node
		elif anim_time >= pose_anim.current_animation_length:
			# Animation done, no next -> Return to CHASING
			finished.emit(CHASING);


func exit() -> void:
	hit_shapecast.enabled = false;
	curr_atk = null;
	pending_attacks = [];
