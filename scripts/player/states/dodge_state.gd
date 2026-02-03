# Player Dodge State
extends State

@onready var player: CharacterBody2D = owner
var dodge_timer: float = 0.0


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	player.dodge()
	player.sprite.play("dodge")
	dodge_timer = player.stats.dodge_duration


func exit() -> void:
	super.exit()
	player.end_dodge()


func physics_update(delta: float) -> void:
	dodge_timer -= delta
	
	# Apply dodge velocity
	player.velocity.x = player.dodge_direction.x * player.stats.dodge_speed
	player.velocity.y = player.dodge_direction.y * player.stats.dodge_speed * 0.5  # Less vertical dodge
	
	# End dodge
	if dodge_timer <= 0:
		if player.is_on_floor():
			state_machine.change_state(&"Idle")
		else:
			state_machine.change_state(&"Fall")


func handle_input(_event: InputEvent) -> void:
	# Cannot cancel dodge
	pass
