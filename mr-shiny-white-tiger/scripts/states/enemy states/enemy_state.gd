class_name EnemyState extends State

const READY = "Ready"
const CHASING = "Chasing"
const CIRCLING = "Circling"
const AIR = "Air"
const ATTACKING = "Attacking"
const GETTING_HIT = "Getting_Hit"
const RETURNING = "Returning"
const RECOVERING = "Recovering"
const DEATH = "Death"

var this_enemy: Enemy

@export var pose_anim: AnimationPlayer;
@export var face_anim: AnimationPlayer;


func _ready() -> void:
	this_enemy = owner as Enemy;
