extends AudioStreamPlayer

@export var sfx_volume_test_snd : AudioStream;
@export var game_start_snd : AudioStream;


func _on_effects_volume_slider_value_changed() -> void:
	stream = sfx_volume_test_snd;
	play();



func _on_play_button_pressed() -> void:
	stream = game_start_snd;
	play();
