# Player Death State
extends State

@onready var player: CharacterBody2D = owner


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	player.sprite.play("death")
	
	# Disable collision
	player.set_collision_layer_value(1, false)
	player.set_collision_mask_value(1, false)
	
	# Stop movement
	player.velocity = Vector2.ZERO
	
	# Wait for animation, then trigger game over
	await player.sprite.animation_finished
	await player.get_tree().create_timer(1.0).timeout
	
	# Trigger dungeon failure if in dungeon
	if GameManager.is_in_dungeon:
		GameManager.fail_dungeon()
		EventBus.scene_change_requested.emit("res://scenes/village/village.tscn")
	else:
		# In village somehow? Just respawn
		EventBus.scene_change_requested.emit("res://scenes/village/village.tscn")


func physics_update(_delta: float) -> void:
	# No movement while dead
	player.velocity.x = 0


func handle_input(_event: InputEvent) -> void:
	# Cannot act while dead
	pass
