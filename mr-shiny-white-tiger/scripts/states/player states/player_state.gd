class_name PlayerState extends State

const IDLE = "Idle"
const RUNNING = "Running"
const AIR = "Air"
const ATTACKING = "Attacking"
const GETTING_HIT = "Getting_Hit"
const GRAPPLING = "Grappling"
const DODGING = "Dodging"
const RECOVERING = "Recovering"
const DEATH = "Death"

var player: Player

var special_mode_on : bool = false;

@export var pose_anim: AnimationPlayer;
@export var face_anim: AnimationPlayer;

func _ready() -> void:
	player = owner as Player;


# Activated by signal from the style manager
func set_special_mode(setting : bool) -> void:
	special_mode_on = setting;
