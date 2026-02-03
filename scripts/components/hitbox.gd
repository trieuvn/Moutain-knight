# Hitbox Component - Deals damage to Hurtboxes
class_name Hitbox
extends Area2D

signal hit_landed(hurtbox: Hurtbox)

@export var damage: float = 10.0
@export var knockback_force: float = 200.0
@export var damage_type: int = 0  # GameConstants.DamageType
@export var can_hit_multiple: bool = false

var owner_entity: Node2D
var has_hit: Array[Node2D] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	# Default to disabled
	monitoring = false
	monitorable = false


func enable() -> void:
	monitoring = true
	monitorable = true
	has_hit.clear()


func disable() -> void:
	monitoring = false
	monitorable = false


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		var hurtbox := area as Hurtbox
		
		# Don't hit ourselves
		if hurtbox.owner_entity == owner_entity:
			return
		
		# Check if already hit (for single-hit attacks)
		if not can_hit_multiple and hurtbox.owner_entity in has_hit:
			return
		
		has_hit.append(hurtbox.owner_entity)
		
		# Calculate knockback direction
		var knockback_dir := Vector2.ZERO
		if owner_entity and hurtbox.owner_entity:
			knockback_dir = (hurtbox.owner_entity.global_position - owner_entity.global_position).normalized()
		
		# Apply damage through hurtbox
		hurtbox.take_damage(damage, knockback_dir * knockback_force, damage_type, owner_entity)
		hit_landed.emit(hurtbox)
