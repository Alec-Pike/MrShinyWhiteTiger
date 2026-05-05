extends TextureProgressBar

@export var this_enemy : Enemy;

func _ready() -> void:
	max_value = this_enemy.hp;
	min_value = 0;


func _process(_delta: float) -> void:
	value = this_enemy.hp;


func _value_changed(new_value: float) -> void:
	if new_value <= 0:
		visible = false;
