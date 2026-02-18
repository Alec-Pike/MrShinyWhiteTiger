class_name AttackResource
extends Resource

@export_category("Animation")
@export var animation_name : StringName;
@export var active_time_start : float;
@export var active_time_end : float;
@export var transition_ok_time : float;
@export_category("Stats")
@export var damage : int;
@export var hit_shape : Shape3D;
@export var hit_range : float;
@export var knockback : Vector3 = Vector3(0, 0, 0.5);
@export_category("Next Attacks")
@export var next_light_atk : AttackResource = null;
@export var next_heavy_atk : AttackResource = null;
