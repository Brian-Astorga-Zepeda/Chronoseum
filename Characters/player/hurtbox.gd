extends Area3D
class_name Hurtbox

## Put this directly under the character body. It auto-finds the
## CombatComponent on its parent, so no manual wiring needed in the editor.

var owner_body: Node3D

func _ready() -> void:
	owner_body = get_parent()

func receive_hit(damage: float, poise_damage: float) -> void:
	if owner_body and owner_body.has_node("CombatComponent"):
		owner_body.get_node("CombatComponent").take_damage(damage, poise_damage)
