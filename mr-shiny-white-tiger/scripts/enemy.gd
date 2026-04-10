class_name Enemy extends CharacterBody3D

@export var detection_range : float = 25.0;
@export var fov : float = 75.0;
@export var run_speed : float = 10.0;
@export var atk_range : float = 3.0;
@export var chase_time_out_threshold : float = 20.0;
@export var min_circle_time : float = 0.0;
@export var max_circle_time : float = 15.0;

func _ready() -> void:
	fov = deg_to_rad(fov);

# Damage taking
signal taking_damage(amount: int, knockback: Vector3);
func take_damage(amount: int, knockback: Vector3):
	taking_damage.emit(amount, knockback);
