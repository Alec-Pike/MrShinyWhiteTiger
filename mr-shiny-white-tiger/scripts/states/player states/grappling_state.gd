extends PlayerState

@export var grapple_speed: float = 20.0 # How fast you travel through the air
@export var grapple_stop_distance: float = 1.0 # How close to get before "letting go"
@export var targeting_system: Node3D;
@export var character_pivot: Node3D;
@export var character_model: Node3D;
@export var target_position_y_offset: float = 1.0;
@export var finishing_boost: float = 25.0;
@export var gravity : float = 75.0;
@export var grapple_anim : StringName;
@export var rotation_speed: float = 5.0;
@export var rope_mesh: MeshInstance3D;
@export var rope_origin: Node3D;
var grapple_target_point: Vector3;

func _ready() -> void:
	# Crucial: Duplicate the mesh resource so changing its length 
	# doesn't affect other entities sharing the same CylinderMesh.
	rope_mesh.mesh = rope_mesh.mesh.duplicate();
	rope_mesh.hide();
	
	if !player: # duct tape fix
		player = $"../..";

# I had a lot of help from Google Gemini

func enter(previous_state_path: String, _data := {}) -> void:
	if !targeting_system.current_grapple_target: 
		finished.emit(previous_state_path);
		return;
	
	grapple_target_point = targeting_system.current_grapple_target.global_position;
	# OPTIONAL: Add a small offset so you land ON TOP of the ledge, not inside it
	grapple_target_point.y += target_position_y_offset;
	# Calculate the velocity ONCE at the start
	player.velocity = calculate_arc_velocity(player.global_position, grapple_target_point, grapple_speed);
	pose_anim.play(grapple_anim, 0.1);
	character_model.rotation_degrees.x = 90;
	character_pivot.look_at(grapple_target_point);


# Calculates initial velocity for grappling
func calculate_arc_velocity(start_pos: Vector3, target_pos: Vector3, speed: float) -> Vector3:
	# 1. Calculate the distance and time to get there
	var displacement = target_pos - start_pos;
	var distance = displacement.length();
	var time = distance / speed;
	# Prevent division by zero if we are already there
	if time <= 0.0: return Vector3.ZERO;
	# 2. Get the gravity vector (assume standard Godot gravity pointing down)
	var gravity_vec = Vector3.DOWN * gravity;
	# 3. The Projectile Motion Formula
	# velocity = (displacement - 0.5 * gravity * time^2) / time
	var velocity_y_component = 0.5 * gravity_vec * time * time;
	var initial_velocity = (displacement - velocity_y_component) / time;
	
	return initial_velocity;
#endfunc


func update_rope(start_pos: Vector3, end_pos: Vector3) -> void:
	# Prevent math errors if the points are exactly the same
	if start_pos.is_equal_approx(end_pos): return
	
	var distance: float = start_pos.distance_to(end_pos)
	
	# 1. Scale the cylinder's height to match the distance
	# The casting is necessary to prevent the static type checker
	# from getting mad
	var cylinder: CylinderMesh = rope_mesh.mesh as CylinderMesh
	cylinder.height = distance
	
	# 2. Position the mesh exactly halfway between start and end
	rope_mesh.global_position = start_pos.lerp(end_pos, 0.5)
	
	# 3. Orient the mesh
	var direction: Vector3 = start_pos.direction_to(end_pos)
	var up_vector: Vector3 = Vector3.UP
	
	# Fallback to prevent look_at() errors when aiming straight up or down
	if abs(direction.y) > 0.999:
		up_vector = Vector3.RIGHT
		
	rope_mesh.look_at(end_pos, up_vector)
	
	# Godot's CylinderMesh aligns to the Y-axis by default.
	# look_at() points the negative Z-axis at the target.
	# We must rotate the mesh 90 degrees locally on the X-axis to align the cylinder correctly.
	rope_mesh.rotate_object_local(Vector3.RIGHT, PI / 2.0)


func physics_update(delta: float) -> void:
	# 1. Apply Gravity (Critical for the arc to work!)
	# The initial velocity we calculated ASSUMES gravity will be dragging us down.
	player.velocity.y -= gravity * delta;
	# 2. Check if we reached the target
	if player.global_position.distance_to(grapple_target_point) < grapple_stop_distance:
		print("reached grapple target successfully");
		player.velocity.y = finishing_boost;
		finished.emit(AIR, {"jumping": false});
		return;
	player.move_and_slide();
	
	# Failsafe in case player bonks into something and can't complete the trajectory	
	# Calculate the vector pointing FROM player TO target
	var direction_to_target: Vector3 = player.global_position.direction_to(grapple_target_point);
	var current_velocity_dir: Vector3 = player.velocity.normalized();
	# Calculate the Dot Product
	var alignment: float = current_velocity_dir.dot(direction_to_target);
	# Check 1: Are we moving AWAY? (Dot product is negative)
	# Check 2: Did we hit a wall? (Standard Godot check)
	if alignment < -0.1: #|| player.is_on_wall():
		print("out of alignment; aborting grapple");
		# Stop the grapple immediately so we don't slide into orbit
		player.velocity = Vector3.ZERO;
		finished.emit(AIR, {"jumping": false}); # Transition to a Fall or Wall Slide state
		return;
#endfunc


func update(_delta: float) -> void:
	point_top_smoothly(player.global_position + player.velocity, _delta);
	rope_mesh.show();
	update_rope(rope_origin.global_position, grapple_target_point - Vector3.UP * target_position_y_offset);


func point_top_smoothly(target_position: Vector3, delta: float):
	# 1. Get the direction from the pivot to the target
	var direction = character_pivot.global_position.direction_to(target_position)
	
	# Prevent math errors if the target is in the exact same spot as the pivot
	if direction.is_zero_approx():
		return
		
	# 2. Calculate the "Goal" Basis. 
	# Basis.looking_at() calculates what the rotation SHOULD be if it looked at the direction.
	# We use Vector3.UP to tell it which way the "top" of the pivot should face.
	var target_basis = Basis.looking_at(direction, Vector3.UP)
	
	# 3. Slerp the pivot's current rotation towards the goal rotation
	character_pivot.global_basis = character_pivot.global_basis.slerp(target_basis, rotation_speed * delta)
	
	# 4. Cleanup: Slerping over a long time can introduce tiny floating-point errors.
	# Orthonormalizing ensures the pivot's scale remains exactly 1,1,1 and doesn't warp.
	character_pivot.global_basis = character_pivot.global_basis.orthonormalized()


func exit() -> void:
	character_model.rotation_degrees.x = 0;
	character_pivot.rotation_degrees.x = 0;
	rope_mesh.hide();
