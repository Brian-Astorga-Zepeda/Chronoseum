extends CharacterBody3D

@export var speed: float = 6.0
@export var gravity: float = 20.0
@onready var pivot: Node3D = $Pivot
enum State { IDLE, MOVE, ATTACK}

var state: State = State.IDLE
var state_time: float = 0.0	
@onready var weapon_hitbox: Area3D = $Pivot/WeaponHitbox

@export var attack_duration: float = 0.5
@export var attack_active_start: float = 0.15
@export var attack_active_end: float = 0.28

func _physics_process(delta: float) -> void:
	state_time += delta
	if Input.is_action_just_pressed("attack") and (state == State.IDLE or state == State.MOVE):
		state_time = 0
		state = State.ATTACK
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	match state:
		State.IDLE, State.MOVE:
			_movement_state()
		State.ATTACK:
			_attack_state()

	move_and_slide()

func _movement_state() -> void:
	var input_dir := Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed

	if input_dir.length() > 0.1:
		state = State.MOVE
		pivot.rotation.y = atan2(input_dir.x, input_dir.z)
	else:
		state = State.IDLE

func _attack_state() -> void:
	print("ATTACKING")
	velocity.x = 0
	velocity.z = 0
	weapon_hitbox.monitoring = state_time >= attack_active_start and state_time <= attack_active_end
	if state_time > attack_duration:
		state_time = 0
		state = State.IDLE
