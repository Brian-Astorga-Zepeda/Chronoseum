extends CharacterBody3D

@export var speed: float = 3.5
@export var gravity: float = 20.0
@export var attack_range: float = 1.8
var player: Node3D = null
enum State { CHASE, ATTACK, HITSTUN }

enum AttackPhase {WINDUP, ACTIVE, RECOVER} #DERIVA DEL ESTADO DE ATAQUE, DEBERIA HACER MÁS FACIL INTEGRAR ANIMACIONES

var attack_phase: AttackPhase
var phase_time: float = 0.0
var state: State = State.CHASE
var state_time: float = 0.0
@export var hitstun_duration: float = 5.0
@onready var combat: Node = $CombatComponent
@onready var weapon_hitbox: Area3D = $Pivot/WeaponHitbox
@export var windup_duration: float = 0.6
@export var active_duration: float = 0.2
@export var recover_duration: float = 0.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var players= get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
	combat.was_hit.connect(_on_was_hit)


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _physics_process(delta: float) -> void:
	state_time += delta
	match state:
		State.CHASE:
			_chase_state()
		State.HITSTUN:
			_hitstun_state()
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()
func _on_was_hit() -> void:
	if state != State.HITSTUN:
		state_time = 0
		state = State.HITSTUN
		
		
func _chase_state():
	print("Imchasingyou.")
	if player:
		# TODO: get direction from this enemy to the player (player.global_position - global_position)
		var playerDir: Vector3= Vector3.ZERO
		playerDir.x = player.global_position.x - global_position.x
		playerDir.z = player.global_position.z - global_position.z
		playerDir.y = 0
		var distance = playerDir.length()
		var direction = atan2(playerDir.x, playerDir.z)
		if distance > attack_range:
			var move_dir = playerDir.normalized()
			velocity.x = move_dir.x * speed
			velocity.z = move_dir.z * speed
			rotation.y = direction
		else:
			velocity.x = 0
			velocity.z = 0
func _hitstun_state() -> void:
	velocity.x = 0
	velocity.z = 0
	if state_time > hitstun_duration:
		state = State.CHASE

func enter_atack() -> void:
	#entra en attackphase e inicia el windup
	state = State.ATTACK
	state_time = 0.0
	attack_phase = AttackPhase.WINDUP
	phase_time = 0.0
	#insert windup anim LOL

func state_atack(delta: float) -> void:
	#maneja las fases
	phase_time += delta 
	match attack_phase:
		AttackPhase.WINDUP:
			#velocity = 0 y el enemigo aun puede mirar al jugador
			velocity.x = 0
			velocity.z = 0
			if phase_time >= windup_duration:
				AttackPhase.ACTIVE
		AttackPhase.ACTIVE:
			weapon_hitbox.monitoring = true
			if phase_time >= windup_duration + active_duration:
				AttackPhase.RECOVER
		AttackPhase.RECOVER:
			if phase_time <= windup_duration + active_duration + recover_duration:
				AttackPhase.WINDUP
				State.CHASE
