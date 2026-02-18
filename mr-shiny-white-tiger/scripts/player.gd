class_name Player extends CharacterBody3D

# Damage taking
signal taking_damage(amount: int, knockback: Vector3);
func take_damage(amount: int, knockback: Vector3):
	taking_damage.emit(amount, knockback);
