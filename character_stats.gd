extends Node2D


signal max_health_changed(new_max_health)
signal health_changed(new_health)
signal no_health

@export var max_health: int = 10:
	set(new_max_health):
		max_health = new_max_health
		if current_health != null:
			self.current_health = min(current_health, max_health)
		emit_signal("max_health_changed", max_health)
@export var attack_speed: float = 0.5 ## seconds between attacks5
@export var fishing_accuracy: float = 0.05 ## with this margin for error when accurate timing
@export var fishing_inaccuracy: float = 0.25 ## up to this far away when inaccurate timing


@onready var current_health = max_health:
	set(new_health):
		current_health = new_health
		emit_signal("health_changed", current_health)
		if current_health <= 0:
			emit_signal("no_health")


