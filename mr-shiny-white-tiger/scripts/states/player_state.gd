class_name PlayerState extends State

const IDLE = "Idle"
const RUNNING = "Running"
const AIR = "Air"
const ATTACKING = "Attacking"
const GETTING_HIT = "Getting_Hit"
const GRAPPLING = "Grappling"
const SPECIAL_ATK = "Special_Atk"

var player: Player

@export var pose_anim: AnimationPlayer;
@export var face_anim: AnimationPlayer;

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

# Can be overridden by specific states
# also now we don't have to do duck typing :D
func is_invulnerable() -> bool:
	return false
