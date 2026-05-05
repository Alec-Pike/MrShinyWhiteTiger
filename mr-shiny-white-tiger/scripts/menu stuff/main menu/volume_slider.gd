extends HSlider

@export var audio_bus_name : String;
@onready var audio_bus_id : int = AudioServer.get_bus_index(audio_bus_name);

func _value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(audio_bus_id, linear_to_db(value));
