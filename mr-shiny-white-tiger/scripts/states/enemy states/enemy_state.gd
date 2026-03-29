class_name EnemyState extends State

const READY = "Ready"
const CHASING = "Chasing"
const AIR = "Air"
const ATTACKING = "Attacking"
const GETTING_HIT = "Getting_Hit"

var this_enemy: Enemy

@export var pose_anim: AnimationPlayer;
@export var face_anim: AnimationPlayer;

func _ready() -> void:
	await owner.ready
	this_enemy = owner as Enemy
	assert(this_enemy != null, "The EnemyState state type must be used only in enemy scenes. It needs the owner to be an Enemy node.")

# Can be overridden by specific states
# also now we don't have to do duck typing :D
func is_invulnerable() -> bool:
	return false
