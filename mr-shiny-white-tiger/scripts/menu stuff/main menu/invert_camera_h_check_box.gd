extends CheckBox

func _toggled(toggled_on: bool) -> void:
	Global.invert_camera_h = toggled_on;
