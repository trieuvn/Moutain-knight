# Hurtbox Component - Receives damage from Hitboxes
class_name Hurtbox
extends Area2D

signal damage_received(amount: float, knockback: Vector2, damage_type: int, attacker: Node2D)

@export var is_invincible: bool = false

const HIT_IMPACT = preload("res://scenes/effects/hit_impact.tscn")

var owner_entity: Node2D
var invincibility_timer: float = 0.0


func _ready() -> void:
	# Hurtbox should be on a different layer than hitbox
	pass


func _process(delta: float) -> void:
	if invincibility_timer > 0:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false


func take_damage(amount: float, knockback: Vector2, damage_type: int, attacker: Node2D) -> void:
	if is_invincible:
		return
	
	damage_received.emit(amount, knockback, damage_type, attacker)
	
	# Spawn hit particle effect
	_spawn_hit_effect()
	
	# Camera shake on hit
	if has_node("/root/CameraShake"):
		get_node("/root/CameraShake").shake(3.0, 0.15)


func _spawn_hit_effect() -> void:
	var effect = HIT_IMPACT.instantiate()
	effect.global_position = global_position
	get_tree().current_scene.add_child(effect)


func set_invincible(duration: float) -> void:
	is_invincible = true
	invincibility_timer = duration
