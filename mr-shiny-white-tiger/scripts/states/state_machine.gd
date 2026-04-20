# Based on this tutorial:
# https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/

class_name StateMachine extends Node

@export var debug_messages: bool = false;

@export var initial_state: State = null;
@export var damage_state: State = null;
@onready var damage_state_path: NodePath = damage_state.get_path() if damage_state else ^"";

@onready var state: State = initial_state if initial_state else get_child(0);


func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state);

	await owner.ready;
	state.enter(initial_state.get_path());
	
	owner.taking_damage.connect(_on_getting_hit)

func _on_getting_hit(damage: int, knockback: Vector3, attacker_position: Vector3):
	# 1. OPTIONAL: Check for "Super Armor"
	# If the current state has a flag saying "cannot be interrupted", ignore this.
	if state.is_invulnerable():
		return

	# 2. Force the transition
	# We pass the knockback vector and attacker's rotation so the Hurt state knows which way to fly
	_transition_to_next_state(damage_state_path, {"damage": damage, "knockback": knockback, "attacker_position": attacker_position})


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event);


func _process(delta: float) -> void:
	state.update(delta);


func _physics_process(delta: float) -> void:
	state.physics_update(delta);


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.");
		return;

	var previous_state_path := state.name;
	state.exit();
	state = get_node(target_state_path);
	state.enter(previous_state_path, data);
	if debug_messages:
		print(owner.name + " transitioned to state " + state.name);
