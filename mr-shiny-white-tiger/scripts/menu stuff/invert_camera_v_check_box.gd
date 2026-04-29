extends CheckBox

func _toggled(toggled_on: bool) -> void:
	Global.invert_camera_v = toggled_on;
