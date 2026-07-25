extends Area3D

@export var damage: float = 10.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	area.receive_hit(damage)
