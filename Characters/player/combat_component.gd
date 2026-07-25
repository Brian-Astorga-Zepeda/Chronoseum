extends Node
class_name CombatComponent

## Reusable on both player and enemies.
## Handles health, stamina, poise (hit-stun resistance) and i-frames.

signal health_changed(current: float, max_value: float)
signal poise_broken
signal died

@export var max_health: float = 100.0
@export var max_stamina: float = 100.0
@export var max_poise: float = 50.0
@export var stamina_regen_rate: float = 15.0
@export var poise_regen_rate: float = 20.0
@export var poise_regen_delay: float = 2.0

var health: float
var stamina: float
var poise: float
var is_invincible: bool = false
var is_dead: bool = false

var _poise_regen_timer: float = 0.0

func _ready() -> void:
	health = max_health
	stamina = max_stamina
	poise = max_poise

func _physics_process(delta: float) -> void:
	stamina = min(max_stamina, stamina + delta * stamina_regen_rate)

	if poise < max_poise:
		_poise_regen_timer += delta
		if _poise_regen_timer >= poise_regen_delay:
			poise = min(max_poise, poise + delta * poise_regen_rate)

func take_damage(amount: float, poise_damage: float) -> void:
	if is_invincible or is_dead:
		return

	health -= amount
	poise -= poise_damage
	_poise_regen_timer = 0.0
	health_changed.emit(health, max_health)

	if poise <= 0.0:
		poise = max_poise
		poise_broken.emit()

	if health <= 0.0:
		health = 0.0
		is_dead = true
		died.emit()

func use_stamina(amount: float) -> bool:
	if stamina >= amount:
		stamina -= amount
		return true
	return false
