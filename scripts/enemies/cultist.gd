# Cultist Enemy - Dark magic user
extends "res://scripts/enemies/base_enemy.gd"

func _load_sprites() -> void:
	if sprite:
		SpriteLoader.setup_cultist_sprite_frames(sprite)


func _ready() -> void:
	# Cultist is weaker but can cast spells (future: ranged attacks)
	max_hp = 45.0
	attack_damage = 20.0
	move_speed = 70.0
	attack_range = 80.0  # Longer range for spell casting
	blood_coin_reward = 20
	
	super._ready()
