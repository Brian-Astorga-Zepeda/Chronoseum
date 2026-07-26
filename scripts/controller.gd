extends CharacterBody3D

@onready var combat: Node = $CombatComponent
@export var attack_stamina_cost: float = 20.0
@export var speed: float = 6.0
@export var gravity: float = 20.0
@onready var pivot: Node3D = $Pivot
enum State { IDLE, MOVE, ATTACK, DODGE }

@export var dodge_speed: float = 14.0
@export var dodge_duration: float = 0.35
@export var dodge_invincible_duration: float = 0.2
@export var dodge_stamina_cost: float = 15.0

var dodge_direction: Vector3 = Vector3.ZERO
var state: State = State.IDLE
var state_time: float = 0.0	
@onready var weapon_hitbox: Area3D = $Pivot/WeaponHitbox

@export var attack_duration: float = 0.5
@export var attack_active_start: float = 0.15
@export var attack_active_end: float = 0.28

func _physics_process(delta: float) -> void:
	state_time += delta
	if Input.is_action_just_pressed("attack") and (state == State.IDLE or state == State.MOVE) and combat.use_stamina(attack_stamina_cost):
		state_time = 0
		state = State.ATTACK
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	if Input.is_action_just_pressed("dodge") and (state == State.IDLE or state == State.MOVE or state == State.ATTACK) and combat.use_stamina(dodge_stamina_cost):
		state_time = 0
		state = State.DODGE
		dodge_direction = Vector3.ZERO
		dodge_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		dodge_direction.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

		if dodge_direction.length() > 0.1:
			dodge_direction = dodge_direction.normalized()
		else:
			dodge_direction = pivot.transform.basis.z
	match state:
		State.IDLE, State.MOVE:
			_movement_state()
		State.ATTACK:
			_attack_state()
		State.DODGE:
			_dodge_state()

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
	velocity.x = 0
	velocity.z = 0
	weapon_hitbox.monitoring = state_time >= attack_active_start and state_time <= attack_active_end
	if state_time > attack_duration:
		state_time = 0
		state = State.IDLE
		
func _dodge_state() -> void:
	print("test")
