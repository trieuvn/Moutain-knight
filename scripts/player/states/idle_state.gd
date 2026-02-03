# Player Idle State
extends State

@onready var player: CharacterBody2D = owner


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	player.sprite.play("idle")


func physics_update(delta: float) -> void:
	# Get input
	player.get_input_direction()
	
	# Transitions
	if player.input_direction.x != 0:
		state_machine.change_state(&"Move")
		return
	
	if not player.is_on_floor():
		state_machine.change_state(&"Fall")
		return
	
	# Decelerate
	player.stop_horizontal()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		state_machine.change_state(&"Jump")
	elif event.is_action_pressed("dodge"):
		state_machine.change_state(&"Dodge")
	elif event.is_action_pressed("light_attack"):
		state_machine.change_state(&"LightAttack")
	elif event.is_action_pressed("heavy_attack"):
		state_machine.change_state(&"HeavyAttack")
