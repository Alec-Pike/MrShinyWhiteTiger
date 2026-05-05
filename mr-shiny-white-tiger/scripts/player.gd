class_name Player extends CharacterBody3D


@export var starting_hp : int;
@export var health_bar : TextureProgressBar;
var hp : int;


func _enter_tree():
	Global.player = self
	Global.game_init();


func _ready() -> void:
	health_bar.max_value = starting_hp;
	health_bar.min_value = 0;
	
	hp = starting_hp;


func _process(_delta: float) -> void:
	if hp > starting_hp:
		hp = starting_hp;
	
	health_bar.value = hp;


# Damage taking
signal taking_damage(damage: int, knockback: Vector3, attacker_rotation: Vector3);
func take_damage(damage: int, knockback: Vector3, attacker_rotation: Vector3):
	taking_damage.emit(damage, knockback, attacker_rotation);


# Death
signal is_dead();
func die():
	is_dead.emit();
	#queue_free();
