extends State

@export_category("References")
@export var character : CharacterBody3D;
@export var character_model : VRMTopLevel;
@export var to_deactivate : Array[Node];
@export_category("Animation")
@export var death_anim_name : StringName;
@export var fade_duration : float = 2.0;
@export var pose_anim : AnimationPlayer;
@export var face_anim : AnimationPlayer;



func enter(_previous_state_path: String, _data := {}) -> void:
	# Stop everything
	#TODO: stop game timer here
	character.set_physics_process(false);
	for node in to_deactivate:
		node.set_deferred("disabled", true);
	# Death animation
	pose_anim.play(death_anim_name);
	pose_anim.animation_finished.connect(_on_animation_finished);


func _on_animation_finished(_anim_name: StringName):
	var blink_delay : float = 0.05 # Starting time in seconds between flashes
	const total_blinks : int = 15  # How many times it toggles visibility
	
	# 4. The Retro Flicker Loop
	for i in range(total_blinks):
		# Toggle visibility (if true it becomes false, if false it becomes true)
		character_model.visible = not character_model.visible
		
		# Wait for the current delay before looping again
		await get_tree().create_timer(blink_delay).timeout
		
		# Multiply the delay by a fraction to make it faster each loop!
		# (Remove this line if you want a constant, steady blink rate)
		#blink_delay *= 0.85
	
	#character.die();
	#TODO: go to win screen instead
	get_tree().change_scene_to_file("res://_scenes/main_menu.tscn");


# --- HELPER FUNCTION ---
# This digs through the node tree and returns an array of every MeshInstance3D it finds
func get_all_meshes(node: Node) -> Array[MeshInstance3D]:
	var mesh_list: Array[MeshInstance3D] = []
	
	# If the current node is a mesh, add it to our list
	if node is MeshInstance3D:
		mesh_list.append(node)
		
	# Check all children of this node and run this same function on them
	for child in node.get_children():
		mesh_list.append_array(get_all_meshes(child))
		
	return mesh_list
