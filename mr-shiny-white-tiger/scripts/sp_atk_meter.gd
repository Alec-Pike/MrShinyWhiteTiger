extends TextureProgressBar

@export var filled_overlay: CompressedTexture2D;

func _ready() -> void:
	texture_over = null;

func _value_changed(new_value: float) -> void:
	if new_value >= max_value:
		texture_over = filled_overlay;
	else:
		texture_over = null;
