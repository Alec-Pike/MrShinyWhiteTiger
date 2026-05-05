extends RayCast3D

@onready var shadow_decal : Decal = get_child(0);


func _physics_process(_delta):
	if is_colliding():
		shadow_decal.visible = true
		var hit_point = get_collision_point()
		
		# Move the decal slightly above the hit point so it projects downward
		# The +1 on the Y axis assumes your Decal's Y size is 2
		shadow_decal.global_position = hit_point + Vector3(0, 0.45, 0)
		
		#TODO: maybe in the future scale the blob based on the distance
		
	else:
		# Hide the shadow if the ground is further away than the raycast length
		shadow_decal.visible = false
