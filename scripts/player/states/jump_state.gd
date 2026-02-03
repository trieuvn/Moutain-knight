# Player Jump State
extends State

@onready var player: CharacterBody2D = owner


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	player.jump()
	player.sprite.play("jump")


func physics_update(delta: float) -> void:
	player.get_input_direction()
	player.update_facing_direction()
	
	# Air control
	player.move(player.stats.move_speed * 0.8)
	
	# Transition to fall when velocity goes positive
	if player.velocity.y >= 0:
		state_machine.change_state(&"Fall")
		return


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("dodge"):
		state_machine.change_state(&"Dodge")
	elif event.is_action_pressed("light_attack"):
		state_machine.change_state(&"LightAttack")
	elif event.is_action_pressed("heavy_attack"):
		state_machine.change_state(&"HeavyAttack")
