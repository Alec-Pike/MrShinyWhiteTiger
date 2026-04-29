extends OptionButton

func _ready() -> void:
	item_selected.connect(_on_item_selected);

func _on_item_selected(idx: int):
	const percentages : Array[float] = [1.0, 0.75, 0.5, 0.25];
	get_tree().root.scaling_3d_scale = percentages[idx];
