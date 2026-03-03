@tool
extends EditorScript

func _run():
	# 1. Update this path to where you saved your .res file
	var anim : Animation = load("res://animations/MrShiny/misc/L_Flying_Side_Kick_noXZ.res") 
	if not anim:
		print("Animation not found!")
		return
		
	# 2. Update this to match the exact name of your skeleton/bone track
	# Example: "Skeleton3D:RootBone" or "Armature/Skeleton3D:Hips"
	var track_path = "%GeneralSkeleton:Hips" 
	
	# We are specifically looking for a 3D Position track
	var track_idx = anim.find_track(track_path, Animation.TYPE_POSITION_3D) 
	
	if track_idx == -1:
		print("3D Position Track not found! Check your spelling.")
		return
		
	# 3. Loop through and zero out X and Z
	for i in range(anim.track_get_key_count(track_idx)):
		var val = anim.track_get_key_value(track_idx, i)
		val.x = 0.0
		val.z = 0.0
		anim.track_set_key_value(track_idx, i, val)
		
	# 4. Save the file directly
	ResourceSaver.save(anim, anim.resource_path)
	print("X and Z stripped! Y is intact.")
