# Health Component - Manages HP for any entity
class_name HealthComponent
extends Node

signal health_changed(current: float, max_health: float)
signal damage_taken(amount: float, attacker: Node2D)
signal healed(amount: float)
signal died

@export var max_health: float = 100.0
@export var current_health: float = 100.0


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float, attacker: Node2D = null) -> void:
	var actual_damage = max(0, amount)
	current_health = max(0, current_health - actual_damage)
	
	damage_taken.emit(actual_damage, attacker)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()


func heal(amount: float) -> void:
	var actual_heal = min(amount, max_health - current_health)
	current_health = min(max_health, current_health + actual_heal)
	
	healed.emit(actual_heal)
	health_changed.emit(current_health, max_health)


func set_max_health(value: float, heal_to_full: bool = false) -> void:
	max_health = value
	if heal_to_full:
		current_health = max_health
	else:
		current_health = min(current_health, max_health)
	health_changed.emit(current_health, max_health)


func get_health_percent() -> float:
	return current_health / max_health if max_health > 0 else 0.0


func is_dead() -> bool:
	return current_health <= 0


func reset() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
