extends CharacterBody3D

@export var speed: float = 3.5
@export var gravity: float = 20.0
@export var attack_range: float = 1.8
var player: Node3D = null
enum State { CHASE, HITSTUN }

var state: State = State.CHASE
var state_time: float = 0.0
@export var hitstun_duration: float = 5.0
@onready var combat: Node = $CombatComponent

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
	print("IM ON HITSTUN!!")
	velocity.x = 0
	velocity.z = 0
	if state_time > hitstun_duration:
		print("IM NOT ANYMORE!!")
		state = State.CHASE
