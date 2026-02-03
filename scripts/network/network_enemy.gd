# Network Enemy - Synchronization for enemies in multiplayer
extends Node

# Attached to enemy nodes to handle network sync
# Only host controls enemies, clients receive updates

@export var sync_rate: float = 0.1  # 10 updates per second

var enemy: CharacterBody2D
var target_position: Vector2
var target_velocity: Vector2
var last_sync_time: float = 0.0

var current_animation: String = ""
var current_state: String = ""


func _ready() -> void:
	enemy = get_parent() as CharacterBody2D
	if enemy:
		target_position = enemy.global_position


func _physics_process(delta: float) -> void:
	if not enemy:
		return
	
	if multiplayer.is_server():
		# Host controls enemies
		_send_state_update(delta)
	else:
		# Clients interpolate
		_interpolate_position(delta)


func _send_state_update(delta: float) -> void:
	last_sync_time += delta
	
	if last_sync_time >= sync_rate:
		last_sync_time = 0.0
		_sync_enemy_state.rpc(
			enemy.global_position,
			enemy.velocity,
			_get_current_animation(),
			_get_current_state()
		)


@rpc("authority", "unreliable_ordered")
func _sync_enemy_state(pos: Vector2, vel: Vector2, anim: String, state: String) -> void:
	if multiplayer.is_server():
		return
	
	target_position = pos
	target_velocity = vel
	
	if anim != current_animation:
		current_animation = anim
		_set_animation(anim)
	
	if state != current_state:
		current_state = state


func _interpolate_position(delta: float) -> void:
	enemy.global_position = enemy.global_position.lerp(target_position, 10.0 * delta)


func _get_current_animation() -> String:
	var sprite = enemy.get_node_or_null("AnimatedSprite2D")
	if sprite and sprite is AnimatedSprite2D:
		return sprite.animation
	return "idle"


func _get_current_state() -> String:
	var state_machine = enemy.get_node_or_null("StateMachine")
	if state_machine and state_machine.has_method("get_current_state_name"):
		return state_machine.get_current_state_name()
	return ""


func _set_animation(anim_name: String) -> void:
	var sprite = enemy.get_node_or_null("AnimatedSprite2D")
	if sprite and sprite is AnimatedSprite2D:
		if sprite.sprite_frames.has_animation(anim_name):
			sprite.play(anim_name)


# ====================
# COMBAT SYNC
# ====================
@rpc("authority", "reliable")
func sync_enemy_damage(amount: float, attacker_id: int) -> void:
	# Broadcast damage to all clients
	if not multiplayer.is_server():
		return
	
	_apply_damage_client.rpc(amount)


@rpc("authority", "call_remote", "reliable")
func _apply_damage_client(amount: float) -> void:
	# Visual feedback on clients
	var sprite = enemy.get_node_or_null("AnimatedSprite2D")
	if sprite:
		var tween = enemy.create_tween()
		tween.tween_property(sprite, "modulate", Color(1, 0.5, 0.5), 0.05)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)


@rpc("authority", "reliable")
func sync_enemy_death() -> void:
	_trigger_death_client.rpc()


@rpc("authority", "call_remote", "reliable")
func _trigger_death_client() -> void:
	_set_animation("death")
	
	# Disable collision
	enemy.set_deferred("collision_layer", 0)
	enemy.set_deferred("collision_mask", 0)
