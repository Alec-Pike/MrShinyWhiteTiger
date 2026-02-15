extends Node3D

@export_category("References")
@export var player_obj : CharacterBody3D;
@export var player_pivot : Node3D;
@export var camera : Camera3D;
@export var targeting_shapecast : ShapeCast3D;
@export var hit_shapecast : ShapeCast3D;
@export var animation_player : AnimationPlayer;
@export var combo_timeout_timer : Timer;
@export_category("Starting Attacks")
@export var starting_ground_light_atk : AttackResource;
@export var starting_ground_heavy_atk : AttackResource;
@export var starting_air_light_atk : AttackResource;
@export var starting_air_heavy_atk : AttackResource;
@export_category("Other")
@export var combo_timeout_seconds : float;
@export var attack_cancelling_inputs : Array[String];

var curr_atk : AttackResource = null;
var is_attacking : bool = false;

func _ready():
	combo_timeout_timer.timeout.connect(_on_timer_timeout);

func _process(_delta: float) -> void:
	# Determine if we're starting an attack this frame
	var light_atk_requested : bool = Input.is_action_just_pressed("light_attack");
	var heavy_atk_requested : bool = Input.is_action_just_pressed("heavy_attack");
	var cancel_input_pressed : bool = false;
	for action in attack_cancelling_inputs:
		if Input.is_action_pressed(action):
			cancel_input_pressed = true;
			break;
	#TODO: add other "can't attack" conditions
	var should_we_initiate_attack : bool = (heavy_atk_requested || light_atk_requested) && !cancel_input_pressed && !is_attacking;
	if should_we_initiate_attack:
		is_attacking = true;
		combo_timeout_timer.stop();
		initiate_attack(light_atk_requested, heavy_atk_requested, !player_obj.is_on_floor());
	
	if is_attacking:
		# Check to activate hit
		var anim_timestamp : float = animation_player.current_animation_position;
		if anim_timestamp >= curr_atk.active_time_start && anim_timestamp <= curr_atk.active_time_end:
			hit_shapecast.enabled = true;
			hit_shapecast.force_shapecast_update();
			for i in hit_shapecast.get_collision_count():
				var target: Node3D = hit_shapecast.get_collider(i) as Node3D; #TODO: not as `Node3D`, as `Enemy`
				#TODO: target.take_damage(curr_atk.damage, curr_atk.knockback, player_pivot.global_transform.origin);
				print("Attack '" + curr_atk.animation_name + "' hit target '" + target.name + "'");
		# Check if we can exit the attack
		if anim_timestamp >= curr_atk.transition_ok_time || cancel_input_pressed:
			is_attacking = false;
			hit_shapecast.enabled = false;
#endfunc

func initiate_attack(light_atk_requested: bool, heavy_atk_requested: bool, in_air: bool) -> void:
	# Determine what attack we're doing
	# Advance to appropriate next move (which could be null, i.e. the end of a combo)
	if curr_atk:
		if light_atk_requested:
			curr_atk = curr_atk.next_light_atk;
		elif heavy_atk_requested:
			curr_atk = curr_atk.next_heavy_atk;
	# If we're not in a combo, get first move
	if !curr_atk:
		if light_atk_requested:
			if in_air: curr_atk = starting_air_light_atk;
			else: curr_atk = starting_ground_light_atk;
		elif heavy_atk_requested:
			if in_air: curr_atk = starting_air_heavy_atk;
			else: curr_atk = starting_ground_heavy_atk;
	
	# Perform the attack
	# First, figure out what we're trying to hit,
	# and automatically pivot to face it
	if targeting_shapecast.is_colliding(): 
		var target_position: Vector3 = (targeting_shapecast.get_collider(0) as Node3D).global_transform.origin;
		target_position.y = player_obj.global_transform.origin.y;
		player_pivot.look_at(target_position);
	hit_shapecast.shape = curr_atk.hit_shape;
	hit_shapecast.target_position.z = -curr_atk.hit_range;
	#animation_player.play(curr_atk.animation_name);
	combo_timeout_timer.start(combo_timeout_seconds);
#endfunc

# Reset the combo if it's been a while since we attacked
func _on_timer_timeout() -> void:
	curr_atk = null;
	is_attacking = false; # Will probably be false anyway, but just to be safe (and for my sanity)
