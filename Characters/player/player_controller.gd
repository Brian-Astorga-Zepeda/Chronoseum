extends CharacterBody3D

## Movement is locked to the X/Z plane (Y is gravity only) so the game reads
## like a 2.5D beat-em-up even though everything is real 3D geometry.

@export var speed: float = 6.0
@export var gravity: float = 20.0

@export var dodge_speed: float = 14.0
@export var dodge_duration: float = 0.35
@export var dodge_invincible_duration: float = 0.2
@export var dodge_stamina_cost: float = 15.0

@export var attack_duration: float = 0.5
@export var attack_active_start: float = 0.15
@export var attack_active_end: float = 0.28
@export var attack_stamina_cost: float = 20.0

enum State { IDLE, MOVE, ATTACK, DODGE, HITSTUN, DEAD }

var state: State = State.IDLE
var state_time: float = 0.0
var move_input: Vector3 = Vector3.ZERO
var dodge_direction: Vector3 = Vector3.ZERO
var buffered_attack: bool = false

@onready var pivot: Node3D = $Pivot
@onready var weapon_hitbox: Hitbox = $Pivot/WeaponHitbox
@onready var weapon_mesh: MeshInstance3D = $Pivot/WeaponHitbox/MeshInstance3D
@onready var combat: CombatComponent = $CombatComponent

func _ready() -> void:
	combat.poise_broken.connect(_on_poise_broken)
	combat.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	state_time += delta
	_read_input()

	match state:
		State.IDLE, State.MOVE:
			_movement_state()
		State.ATTACK:
			_attack_state()
		State.DODGE:
			_dodge_state()
		State.HITSTUN:
			_hitstun_state()
		State.DEAD:
			velocity.x = 0.0
			velocity.z = 0.0

	move_and_slide()

func _read_input() -> void:
	move_input = Vector3.ZERO
	move_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_input.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	if move_input.length() > 1.0:
		move_input = move_input.normalized()

	if Input.is_action_just_pressed("attack"):
		if state == State.ATTACK:
			buffered_attack = true  # combo buffer: queued during recovery
		elif state == State.IDLE or state == State.MOVE:
			_enter_attack()

	if Input.is_action_just_pressed("dodge") and (state == State.IDLE or state == State.MOVE):
		_enter_dodge()

func _movement_state() -> void:
	velocity.x = move_input.x * speed
	velocity.z = move_input.z * speed
	state = State.MOVE if move_input.length() > 0.1 else State.IDLE

	if move_input.length() > 0.1:
		pivot.rotation.y = atan2(move_input.x, move_input.z)

func _enter_attack() -> void:
	if not combat.use_stamina(attack_stamina_cost):
		return
	state = State.ATTACK
	state_time = 0.0
	buffered_attack = false
	weapon_hitbox.monitoring = false
	weapon_mesh.visible = false

func _attack_state() -> void:
	velocity.x = 0.0
	velocity.z = 0.0

	var in_active_window := state_time >= attack_active_start and state_time <= attack_active_end
	weapon_hitbox.monitoring = in_active_window
	weapon_mesh.visible = in_active_window

	if state_time > attack_duration:
		if buffered_attack:
			_enter_attack()  # chain into next hit of the combo
		else:
			state = State.IDLE
			state_time = 0.0

func _enter_dodge() -> void:
	if not combat.use_stamina(dodge_stamina_cost):
		return
	state = State.DODGE
	state_time = 0.0
	dodge_direction = move_input.normalized() if move_input.length() > 0.1 else -pivot.transform.basis.z
	combat.is_invincible = true

func _dodge_state() -> void:
	velocity.x = dodge_direction.x * dodge_speed
	velocity.z = dodge_direction.z * dodge_speed

	if state_time >= dodge_invincible_duration:
		combat.is_invincible = false

	if state_time >= dodge_duration:
		state = State.IDLE
		state_time = 0.0
		combat.is_invincible = false

func _hitstun_state() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	if state_time >= 0.6:
		state = State.IDLE
		state_time = 0.0

func _on_poise_broken() -> void:
	if state != State.DEAD:
		state = State.HITSTUN
		state_time = 0.0
		weapon_hitbox.monitoring = false
		weapon_mesh.visible = false

func _on_died() -> void:
	state = State.DEAD
	weapon_hitbox.monitoring = false
	print("Player died")
