extends Area3D

func receive_hit(damage: float) -> void:
	var combat = get_parent().get_node("CombatComponent")
	combat.take_damage(damage)
