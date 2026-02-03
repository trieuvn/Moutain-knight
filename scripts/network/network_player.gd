# Network Player - Synchronization component for multiplayer players
extends Node

# Attached to Player node to handle network synchronization

@export var sync_rate: float = 0.05  # 20 updates per second
@export var interpolation_speed: float = 15.0

var player: CharacterBody2D
var target_position: Vector2
var target_velocity: Vector2
var last_sync_time: float = 0.0

# Animation sync
var current_animation: String = ""
var facing_direction: int = 1


func _ready() -> void:
	player = get_parent() as CharacterBody2D
	if player:
		target_position = player.global_position


func _physics_process(delta: float) -> void:
	if not player:
		return
	
	if is_multiplayer_authority():
		# Local player - send updates
		_send_state_update(delta)
	else:
		# Remote player - interpolate to target
		_interpolate_position(delta)


func _send_state_update(delta: float) -> void:
	last_sync_time += delta
	
	if last_sync_time >= sync_rate:
		last_sync_time = 0.0
		_sync_state.rpc(
			player.global_position,
			player.velocity,
			_get_current_animation(),
			_get_facing_direction()
		)


@rpc("any_peer", "unreliable_ordered")
func _sync_state(pos: Vector2, vel: Vector2, anim: String, facing: int) -> void:
	if is_multiplayer_authority():
		return  # Don't sync for local player
	
	target_position = pos
	target_velocity = vel
	
	# Update animation
	if anim != current_animation:
		current_animation = anim
		_set_animation(anim)
	
	# Update facing
	if facing != facing_direction:
		facing_direction = facing
		_set_facing(facing)


func _interpolate_position(delta: float) -> void:
	# Smooth interpolation for remote players
	player.global_position = player.global_position.lerp(target_position, interpolation_speed * delta)
	player.velocity = target_velocity


func _get_current_animation() -> String:
	var sprite = player.get_node_or_null("AnimatedSprite2D")
	if sprite and sprite is AnimatedSprite2D:
		return sprite.animation
	return "idle"


func _get_facing_direction() -> int:
	var sprite = player.get_node_or_null("AnimatedSprite2D")
	if sprite and sprite is AnimatedSprite2D:
		return -1 if sprite.flip_h else 1
	return 1


func _set_animation(anim_name: String) -> void:
	var sprite = player.get_node_or_null("AnimatedSprite2D")
	if sprite and sprite is AnimatedSprite2D:
		if sprite.sprite_frames.has_animation(anim_name):
			sprite.play(anim_name)


func _set_facing(facing: int) -> void:
	var sprite = player.get_node_or_null("AnimatedSprite2D")
	if sprite and sprite is AnimatedSprite2D:
		sprite.flip_h = facing < 0


# ====================
# COMBAT SYNC
# ====================
@rpc("any_peer", "reliable")
func sync_attack(attack_type: String) -> void:
	if is_multiplayer_authority():
		# Local player - broadcast attack
		_sync_attack_remote.rpc(attack_type)
	else:
		_perform_attack(attack_type)


@rpc("any_peer", "call_remote", "reliable")
func _sync_attack_remote(attack_type: String) -> void:
	_perform_attack(attack_type)


func _perform_attack(attack_type: String) -> void:
	match attack_type:
		"light":
			if player.has_method("light_attack"):
				player.light_attack()
		"heavy":
			if player.has_method("heavy_attack"):
				player.heavy_attack()


@rpc("any_peer", "reliable")
func sync_damage(amount: float, from_position: Vector2) -> void:
	if not is_multiplayer_authority():
		return
	
	# Apply damage locally
	if player.has_method("take_damage"):
		var knockback = (player.global_position - from_position).normalized() * 200
		player.take_damage(amount, knockback)


@rpc("any_peer", "reliable")
func sync_death() -> void:
	if not is_multiplayer_authority():
		_trigger_death_visual()


func _trigger_death_visual() -> void:
	# Play death animation for remote players
	_set_animation("death")
