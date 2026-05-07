class_name Enemy extends CharacterBody3D

@export var hp : int = 100;
@export_category("Ready")
@export var detection_range : float = 25.0;
@export var fov : float = 75.0;
@export_category("Chasing")
@export var chase_speed : float = 10.0;
@export var air_speed : float = 7.0;
# The downward acceleration when in the air, in meters per second squared.
@export var gravity : float = 75.0;
@export_category("Circling")
@export var atk_range : float = 3.0;
@export var min_circle_time : float = 0.0;
@export var max_circle_time : float = 5.0;
@export_category("Returning")
@export var chase_time_out_threshold : float = 20.0;
@export var return_speed : float = 5.0;
@export_category("Attacking")
@export var min_num_atks : int = 1;
@export var max_num_atks : int = 5;
@export var attacks_and_probabilities : Dictionary[AttackResource, float];

@onready var starting_transform : Transform3D = global_transform;
@onready var landing_anim_trigger: RayCast3D = $LandingAnimTrigger

func _ready() -> void:
	fov = deg_to_rad(fov);

func _physics_process(_delta: float) -> void:
	if velocity.y < -100:
		landing_anim_trigger.force_raycast_update();
		if landing_anim_trigger.is_colliding():
			die();

# Damage taking
signal taking_damage(damage: int, knockback: Vector3, attacker_rotation: Vector3);
func take_damage(damage: int, knockback: Vector3, attacker_rotation: Vector3):
	taking_damage.emit(damage, knockback, attacker_rotation);

# Death
signal is_dead();
func die():
	is_dead.emit();
	queue_free();
