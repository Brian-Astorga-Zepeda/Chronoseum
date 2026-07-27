extends Node
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 15.0
@export var max_health: float = 100.0
signal was_hit
var health: float
var stamina: float
var is_invincible: bool = false

func _ready() -> void:
	health = max_health
	stamina = max_stamina

func _physics_process(delta: float) -> void:
	stamina = min(max_stamina, stamina + delta * stamina_regen_rate)

func take_damage(amount: float) -> void:
	if is_invincible:
		return
	health -= amount
	print("current health: " + str(health))

	if health <= 0:
		print("died")
	was_hit.emit()

func use_stamina(amount: float) -> bool:
	print("current stamina:" + str(stamina))
	if stamina >= amount:
		stamina -= amount
		return true
	else:
		print("CANNOT ATTACK")
		return false
