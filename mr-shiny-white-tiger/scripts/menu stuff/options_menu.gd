extends PanelContainer

@onready var invert_camera_h_check_box: CheckBox = $OptionsHBoxContainer/ControlsVBoxContainer/InvertCameraHCheckBox
@onready var invert_camera_v_check_box: CheckBox = $OptionsHBoxContainer/ControlsVBoxContainer/InvertCameraVCheckBox
@onready var fullscreen_check_button: CheckButton = $OptionsHBoxContainer/SystemVBoxContainer/SystemHBoxContainer/ButtonsVBoxContainer/FullscreenCheckButton
@onready var rendering_quality_option_button: OptionButton = $"OptionsHBoxContainer/SystemVBoxContainer/SystemHBoxContainer/ButtonsVBoxContainer/3DRenderingQualityOptionButton"
@onready var voice_volume_slider: HSlider = $OptionsHBoxContainer/SystemVBoxContainer/SystemHBoxContainer/ButtonsVBoxContainer/VoiceVolumeSlider
@onready var effects_volume_slider: HSlider = $OptionsHBoxContainer/SystemVBoxContainer/SystemHBoxContainer/ButtonsVBoxContainer/EffectsVolumeSlider
@onready var music_volume_slider: HSlider = $OptionsHBoxContainer/SystemVBoxContainer/SystemHBoxContainer/ButtonsVBoxContainer/MusicVolumeSlider
@onready var back_button: Button = $BackButton
@onready var main_menu: Control = $"../MainMenu"

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed);

func _on_back_pressed() -> void:
	main_menu._ready();
	
