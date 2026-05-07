extends Enemy;

# Death
func die():
	is_dead.emit();
	#queue_free();
	Global.victory();
