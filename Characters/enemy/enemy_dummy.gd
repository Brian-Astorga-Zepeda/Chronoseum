extends CharacterBody3D

## Minimal souls-style enemy: chases into range, telegraphs (windup) before
## attacking so the player has a real read/react window, then recovers.

@export var speed: float = 3.5
@export var gravity: float = 20.0
@export var attack_range: float = 1.8
@export var windup_duration: float = 0.6
@export var attack_active_duration: float = 0.2
@export var recover_duration: float = 0.8

enum State { CHASE, WINDUP, ATTACK, RECOVER, HITSTUN, DEAD }

var state: State = State.CHASE
var state_time: float = 0.0
var player: Node3D = null

@onready var pivot: Node3D = $Pivot
@onready var weapon_hitbox: Hitbox = $Pivot/WeaponHitbox
@onready var weapon_mesh: MeshInstance3D = $Pivot/WeaponHitbox/MeshInstance3D
@onready var combat: CombatComponent = $CombatComponent

func _ready() -> void:
	combat.poise_broken.connect(_on_poise_broken)
	combat.died.connect(_on_died)
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	state_time += delta

	match state:
		State.CHASE:
			_chase_state()
		State.WINDUP:
			_windup_state()
		State.ATTACK:
			_attack_state()
		State.RECOVER:
			velocity.x = 0.0
			velocity.z = 0.0
			if state_time >= recover_duration:
				_change_state(State.CHASE)
		State.HITSTUN:
			velocity.x = 0.0
			velocity.z = 0.0
			if state_time >= 0.6:
				_change_state(State.CHASE)
		State.DEAD:
			velocity.x = 0.0
			velocity.z = 0.0

	move_and_slide()

func _change_state(new_state: State) -> void:
	state = new_state
	state_time = 0.0

func _chase_state() -> void:
	if not player:
		return
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()

	if dist > attack_range:
		var dir := to_player.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		pivot.rotation.y = atan2(dir.x, dir.z)
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		_change_state(State.WINDUP)

func _windup_state() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	weapon_mesh.visible = true  # telegraph: player can see the attack coming
	if state_time >= windup_duration:
		_change_state(State.ATTACK)
		weapon_hitbox.monitoring = true

func _attack_state() -> void:
	if state_time >= attack_active_duration:
		weapon_hitbox.monitoring = false
		weapon_mesh.visible = false
		_change_state(State.RECOVER)

func _on_poise_broken() -> void:
	if state != State.DEAD:
		_change_state(State.HITSTUN)
		weapon_hitbox.monitoring = false
		weapon_mesh.visible = false

func _on_died() -> void:
	state = State.DEAD
	weapon_hitbox.monitoring = false
	print("Enemy died")
