# Hurtbox Component - Receives damage from Hitboxes
class_name Hurtbox
extends Area2D

signal damage_received(amount: float, knockback: Vector2, damage_type: int, attacker: Node2D)

@export var is_invincible: bool = false

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


func set_invincible(duration: float) -> void:
	is_invincible = true
	invincibility_timer = duration
