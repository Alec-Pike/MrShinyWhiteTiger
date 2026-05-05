extends Timer

@export var level_time_minutes: float;
@export var timer_display: Label;
@onready var level_time_secs: float = level_time_minutes * 60;

func _ready() -> void:
	Global.game_timer = self;
	
	wait_time = level_time_secs;
	one_shot = true;
	
	timeout.connect(_on_timer_timeout);
	
	start();


func _process(_delta: float) -> void:
	# Update the UI every frame
	if !paused:
		var time_left_i: int = ceili(time_left);
		var minutes: int = time_left_i / 60;
		var seconds: int = time_left_i % 60;
		timer_display.text = "%02d:%02d" % [minutes, seconds];


func _on_timer_timeout() -> void:
	Global.player.die();
