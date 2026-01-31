extends Node3D

@export var max_grapple_dist: float = 20.0;
@export var grapple_marker: Control;
@onready var grapple_marker_half_size = grapple_marker.size / 2;
@export var camera: Camera3D;
@export var shape_cast: ShapeCast3D;
@export var player_obj: Node3D;
@onready var player_obj_rid = player_obj.get_rid();

var current_grapple_target: Node3D = null;
@onready var viewport = get_viewport();
@onready var screen_center = viewport.get_visible_rect().size / 2.0;

func _ready() -> void:
	get_tree().root.size_changed.connect(on_viewport_size_changed);
#endfunc

func on_viewport_size_changed() -> void:
	viewport = get_viewport();
	screen_center = viewport.get_visible_rect().size / 2.0;
#endfunc

func _physics_process(_delta: float) -> void:
	update_grapple_target();
	update_ui_marker();
	pass;
#endfunc

func update_grapple_target() -> void:
	shape_cast.force_shapecast_update();
	
	if !shape_cast.is_colliding():
		current_grapple_target = null;
		return;
	
	var best_target: Node3D = null;
	var shortest_dist_to_center: float = INF;
	for i in shape_cast.get_collision_count():
		var target: Node3D = shape_cast.get_collider(i) as Node3D;
		if !target: 
			#print("no valid targets"); 
			continue;
		# Line of sight check
		if !has_line_of_sight(target): 
			#print("no LoS");
			continue;
		# Screen distance checks
		var screen_pos = camera.unproject_position(target.global_position);
		# Check if it's actually on screen
		if !viewport.get_visible_rect().has_point(screen_pos): 
			#print("not on screen");
			continue;
		# Check if it's behind the camera
		if camera.is_position_behind(target.global_position): 
			#print("behind cam");
			continue;
		# Calculate 2D distance from screen center
		var dist_to_center = screen_pos.distance_to(screen_center);
		# May the best distance win!
		if dist_to_center < shortest_dist_to_center:
			shortest_dist_to_center = dist_to_center;
			best_target = target;
			
	# Apply
	current_grapple_target = best_target;
	
#endfunc

func has_line_of_sight(target: Node3D) -> bool:
	var space_state = get_world_3d().direct_space_state;
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, target.global_position);
	query.collision_mask = 1 # Walls/floors only
	query.exclude = [player_obj_rid]; # Player shouldn't block view
	var result = space_state.intersect_ray(query);
	return result.is_empty();
#enfunc

func update_ui_marker() -> void: 
	if current_grapple_target:
		grapple_marker.visible = true;
		var screen_pos = camera.unproject_position(current_grapple_target.global_position);
		grapple_marker.position = screen_pos - grapple_marker_half_size;
		#print("marker should be displayed at " + str(grapple_marker.position)); #debug
	else:
		grapple_marker.visible = false;
#endfunc
