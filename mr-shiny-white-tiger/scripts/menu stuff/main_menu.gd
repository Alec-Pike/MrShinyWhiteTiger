extends Control

@export_category("Main Menu Buttons")
@export var play_btn : Button;
@export var records_btn : Button;
@export var options_btn : Button;
@export var credits_btn : Button;
@export var quit_btn : Button;
@export_category("Refs to other menus")
@export var options_menu : Control;
@export var credits_menu : Control;

func _ready() -> void:
	play_btn.pressed.connect(_on_play_btn_pressed);
	records_btn.pressed.connect(_on_records_btn_pressed);
	options_btn.pressed.connect(_on_options_btn_pressed);
	credits_btn.pressed.connect(_on_credits_btn_pressed);
	quit_btn.pressed.connect(_on_quit_btn_pressed);
	
	self.visible = true;
	options_menu.visible = false;
	credits_menu.visible = false;
	
	play_btn.grab_focus.call_deferred();

func _on_play_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://_scenes/level.tscn");
	#Global.game_init();

func _on_records_btn_pressed() -> void:
	pass

func _on_options_btn_pressed() -> void:
	self.visible = false;
	options_menu.visible = true;

func _on_credits_btn_pressed() -> void:
	self.visible = false;
	credits_menu.visible = true;

func _on_quit_btn_pressed() -> void:
	get_tree().quit();
