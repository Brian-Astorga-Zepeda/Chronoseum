extends CharacterBody3D

@export var speed: float = 6.0
@export var gravity: float = 20.0
@onready var pivot: Node3D = $Pivot
enum State { IDLE, MOVE }

var state: State = State.IDLE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	match state:
		State.IDLE, State.MOVE:
			_movement_state()

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
