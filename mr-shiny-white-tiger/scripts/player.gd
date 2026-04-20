class_name Player extends CharacterBody3D

@export var hp : int = 100;

func _enter_tree():
	Global.player = self

# Damage taking
signal taking_damage(damage: int, knockback: Vector3, attacker_rotation: Vector3);
func take_damage(damage: int, knockback: Vector3, attacker_rotation: Vector3):
	taking_damage.emit(damage, knockback, attacker_rotation);


# Death
signal is_dead();
func die():
	is_dead.emit();
	#queue_free();
