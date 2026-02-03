# Stamina Component - Manages stamina for player actions
class_name StaminaComponent
extends Node

signal stamina_changed(current: float, max_stamina: float)
signal stamina_depleted
signal stamina_recovered

@export var max_stamina: float = 100.0
@export var regen_rate: float = 30.0  # Per second
@export var regen_delay: float = 1.0  # Seconds before regen starts

var current_stamina: float
var regen_timer: float = 0.0
var can_regen: bool = true


func _ready() -> void:
	current_stamina = max_stamina


func _process(delta: float) -> void:
	# Handle regen delay
	if regen_timer > 0:
		regen_timer -= delta
		if regen_timer <= 0:
			can_regen = true
	
	# Regenerate stamina
	if can_regen and current_stamina < max_stamina:
		var old_stamina = current_stamina
		current_stamina = min(max_stamina, current_stamina + regen_rate * delta)
		stamina_changed.emit(current_stamina, max_stamina)
		
		if old_stamina < max_stamina and current_stamina >= max_stamina:
			stamina_recovered.emit()


func use_stamina(amount: float) -> bool:
	if current_stamina < amount:
		stamina_depleted.emit()
		return false
	
	current_stamina = max(0, current_stamina - amount)
	regen_timer = regen_delay
	can_regen = false
	
	stamina_changed.emit(current_stamina, max_stamina)
	return true


func has_enough(amount: float) -> bool:
	return current_stamina >= amount


func get_stamina_percent() -> float:
	return current_stamina / max_stamina if max_stamina > 0 else 0.0


func reset() -> void:
	current_stamina = max_stamina
	regen_timer = 0.0
	can_regen = true
	stamina_changed.emit(current_stamina, max_stamina)
