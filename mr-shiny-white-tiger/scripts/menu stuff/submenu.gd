extends PanelContainer

@export var back_button: Button;
@export var default_focus: Control;
@onready var main_menu: Control = $"../MainMenu";

func _ready() -> void:
	self.visibility_changed.connect(_on_visibility_changed);
	back_button.pressed.connect(_on_back_pressed);

func _on_back_pressed() -> void:
	main_menu._ready();
	
func _on_visibility_changed() -> void:
	if visible:
		default_focus.grab_focus.call_deferred();
