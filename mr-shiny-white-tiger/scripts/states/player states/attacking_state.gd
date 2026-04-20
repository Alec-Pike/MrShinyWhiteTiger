extends PlayerState

@export_category("References")
@export var player_pivot : Node3D;
@export var camera : Camera3D;
@export var targeting_shapecast : ShapeCast3D;
@export var hit_shapecast : ShapeCast3D;
@export var style_score_display : Node;
@export_category("Starting Attacks")
@export var starting_ground_light_atk : AttackResource;
@export var starting_ground_heavy_atk : AttackResource;
@export var starting_air_light_atk : AttackResource;
@export var starting_air_heavy_atk : AttackResource;

signal atk_successful(atk: AttackResource);

var already_hit : bool = false;

var curr_atk : AttackResource = null;
var pending_attack_type : String = "" # For the Input Buffer


func enter(previous_state_path: String, data := {}) -> void:
	player.velocity = Vector3.ZERO; # Stop sliding
	hit_shapecast.enabled = false;
	targeting_shapecast.enabled = true;
	
	var is_air: bool = (previous_state_path == AIR);
	if data.has("type") && data["type"] == "heavy":
		curr_atk = starting_air_heavy_atk if is_air else starting_ground_heavy_atk;
	else:
		curr_atk = starting_air_light_atk if is_air else starting_ground_light_atk;
	
	execute_current_attack();
#endfunc

func execute_current_attack():
	print("curr atk: " + (curr_atk.animation_name if curr_atk else &"Nil"));
	if !curr_atk:
		# Combo over
		if player.is_on_floor():
			finished.emit(IDLE);
		else:
			finished.emit(AIR, {"jumping": false});
		return;

	# Auto-Rotate to face most likely intended target
	targeting_shapecast.force_shapecast_update();
	if targeting_shapecast.is_colliding(): 
		var target_position: Vector3 = (targeting_shapecast.get_collider(0) as Node3D).global_transform.origin;
		target_position.y = player.global_transform.origin.y;
		if target_position != player_pivot.global_transform.origin:
			player_pivot.look_at(target_position);

	# Setup Hitbox
	hit_shapecast.shape = curr_atk.hit_shape
	hit_shapecast.position.z = -curr_atk.hit_range
	
	already_hit = false;
	# Play Animation
	pose_anim.play(curr_atk.animation_name)
	
	# Clear buffer so we don't double-attack
	pending_attack_type = ""


func physics_update(_delta: float) -> void:
	# A. Check for Input Buffering (The "Next" Move)
	if Input.is_action_just_pressed("light_attack"):
		pending_attack_type = "light"
	elif Input.is_action_just_pressed("heavy_attack"):
		pending_attack_type = "heavy"

	# B. Check for Hit Window
	var anim_time : float = pose_anim.current_animation_position;
	
	if anim_time >= curr_atk.active_time_start && anim_time <= curr_atk.active_time_end:
		var dmg_multiplier : int = 2 if special_mode_on else 1;
		var kbk_multiplier : float = 1.5 if special_mode_on else 1.0;
		var final_dmg : int = curr_atk.damage * dmg_multiplier;
		hit_shapecast.enabled = true
		hit_shapecast.force_shapecast_update();
		for i in hit_shapecast.get_collision_count():
			var target: Enemy = hit_shapecast.get_collider(i) as Enemy;
			#FIXME: edit this to only hit each enemy once
			target.take_damage(final_dmg, curr_atk.knockback * kbk_multiplier, player_pivot.global_transform.origin);
			print("Attack '" + curr_atk.animation_name + "' hit target '" + target.name + "'");
			if !already_hit: # Only do this once
				already_hit = true;
				atk_successful.emit(curr_atk);
				# Health steal in special mode
				if special_mode_on:
					player.hp += final_dmg;
	else:
		hit_shapecast.enabled = false

	# C. Check for Transition/Combo Window
	# If the animation is finished (or past the "cancel" point)
	if anim_time >= curr_atk.transition_ok_time:
		if pending_attack_type != "":
			# --- ADVANCE COMBO ---
			# Using the Linked List logic
			if pending_attack_type == "light":
				curr_atk = curr_atk.next_light_atk
			else:
				curr_atk = curr_atk.next_heavy_atk
			
			execute_current_attack() # Recursively start the next node
		
		elif anim_time >= pose_anim.current_animation_length:
			# Animation done, no input -> Return to Idle
			if player.is_on_floor():
				if (
				Input.is_action_pressed("move_forward") ||
				Input.is_action_pressed("move_left") ||
				Input.is_action_pressed("move_right") ||
				Input.is_action_pressed("move_back")
				):
					finished.emit(RUNNING);
				else:
					finished.emit(IDLE);
			else:
				finished.emit(AIR, {"jumping": false});
		#elif (Input.is_action_just_pressed("special_attack")):
			#finished.emit(SPECIAL_ATK);
	
	# These state transitions can cancel an attack
	if player.is_on_floor() && Input.is_action_just_pressed("jump"):
		finished.emit(AIR, {"jumping": true});
	elif (Input.is_action_just_pressed("grapple")):
		finished.emit(GRAPPLING);
	elif (Input.is_action_just_pressed("dodge")):
		finished.emit(DODGING);

func exit() -> void:
	hit_shapecast.enabled = false;
	targeting_shapecast.enabled = false;
	curr_atk = null;
	pending_attack_type = "";
