# Enemy Death State
extends State

@onready var enemy: BaseEnemy = owner
const BLOOD_COIN = preload("res://scenes/pickups/blood_coin.tscn")
const DEATH_EXPLOSION = preload("res://scenes/effects/death_explosion.tscn")


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	enemy.sprite.play("death")
	enemy.velocity = Vector2.ZERO
	enemy.is_dead = true
	
	# Emit death event
	EventBus.enemy_killed.emit(enemy, enemy.blood_coin_reward)
	
	# Spawn death explosion effect
	var explosion = DEATH_EXPLOSION.instantiate()
	explosion.global_position = enemy.global_position
	enemy.get_parent().add_child(explosion)
	
	# Wait for animation then remove
	await enemy.sprite.animation_finished
	await enemy.get_tree().create_timer(0.5).timeout
	
	# Spawn blood coins
	_spawn_coins()
	
	# Fade out and remove
	var tween = enemy.create_tween()
	tween.tween_property(enemy.sprite, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	enemy.queue_free()


func _spawn_coins() -> void:
	# Spawn coins worth the reward value
	var num_coins = max(1, enemy.blood_coin_reward / 10)  # 1 coin per 10 reward value
	
	for i in num_coins:
		var coin = BLOOD_COIN.instantiate()
		coin.coin_value = enemy.blood_coin_reward / num_coins
		coin.global_position = enemy.global_position + Vector2(randf_range(-20, 20), randf_range(-30, -10))
		enemy.get_parent().add_child(coin)
		
		# Add slight delay between coin spawns
		await enemy.get_tree().create_timer(0.05).timeout


func physics_update(_delta: float) -> void:
	enemy.velocity.x = 0


func handle_input(_event: InputEvent) -> void:
	pass
