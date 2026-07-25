extends Area3D
class_name Hitbox

## Attach to weapon bones/sockets. Toggle `monitoring` on/off from your
## state machine or an AnimationPlayer track to match active attack frames.

@export var damage: float = 10.0
@export var poise_damage: float = 15.0

signal hit_landed(hurtbox: Hurtbox)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		hit_landed.emit(area)
		area.receive_hit(damage, poise_damage)
