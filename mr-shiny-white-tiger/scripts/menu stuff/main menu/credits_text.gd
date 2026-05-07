extends RichTextLabel

@export var scroll_speed : float = 30.0;
@export var reset_delay : float = 3.0;
@export var reset_threshold : float = 816.0;

@onready var scrollbar = self.get_v_scroll_bar();

func _ready() -> void:
	self.visibility_changed.connect(_on_visibility_changed);
	print(scrollbar.max_value)

func _process(delta) -> void:
	if scrollbar.value == reset_threshold:
		print("scroll reset triggered!")
		await get_tree().create_timer(reset_delay).timeout;
		scrollbar.value = scrollbar.min_value;
	# Auto-scrolls the text down continuously 
	scrollbar.value += scroll_speed * delta;
	print("scrollbar var = " + str(scrollbar.value))
	
func _on_visibility_changed() -> void:
	scrollbar.value = scrollbar.min_value;
