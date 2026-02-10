# Corrupted Bishop Boss - Simple Implementation
extends BaseEnemy

func _load_sprites() -> void:
	# Will use PixelLab Corrupted Bishop sprites when SpriteLoader is updated
	if sprite:
		# Placeholder - uses base enemy sprite for now
		sprite.modulate = Color(0.8, 0.2, 0.3, 1)  # Dark red tint


func _ready() -> void:
	# Boss stats - much tankier than regular enemies
	max_hp = 300.0
	attack_damage = 25.0
	move_speed = 60.0
	detection_range = 500.0
	attack_range = 60.0
	blood_coin_reward = 100
	
	super._ready()
	
	# Emit boss spawned event
	EventBus.boss_spawned.emit(self)
	EventBus.boss_health_changed.emit(health_component.current_health, max_hp)


func take_damage(amount: float) -> void:
	super.take_damage(amount)
	
	# Update boss health bar
	if health_component:
		EventBus.boss_health_changed.emit(health_component.current_health, max_hp)


func _on_health_depleted() -> void:
	super._on_health_depleted()
	
	# Emit boss defeated event
	EventBus.boss_defeated.emit(self)
