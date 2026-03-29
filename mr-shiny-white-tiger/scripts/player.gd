class_name Player extends CharacterBody3D

func _enter_tree():
	Global.player = self

# Damage taking
signal taking_damage(amount: int, knockback: Vector3);
func take_damage(amount: int, knockback: Vector3):
	taking_damage.emit(amount, knockback);
