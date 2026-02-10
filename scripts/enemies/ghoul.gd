# Ghoul Enemy - Scary walking undead
extends "res://scripts/enemies/base_enemy.gd"

func _load_sprites() -> void:
	if sprite:
		SpriteLoader.setup_ghoul_sprite_frames(sprite)


func _ready() -> void:
	# Ghoul is slightly stronger and faster than skeleton
	max_hp = 60.0
	attack_damage = 18.0
	move_speed = 90.0
	blood_coin_reward = 18
	
	super._ready()
