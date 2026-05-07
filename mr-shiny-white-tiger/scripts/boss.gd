extends Enemy;

# Death
func die():
	is_dead.emit();

	#queue_free();
	Global.victory();

func _process(_delta: float) -> void:
	if global_position.y < 130:
		die();
