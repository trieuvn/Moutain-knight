# Player Heavy Attack State
extends State

@onready var player: CharacterBody2D = owner
var attack_duration: float = 0.0
var hitbox_enabled: bool = false
const HITBOX_START_FRAME: float = 0.3
const HITBOX_END_FRAME: float = 0.45


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	player.heavy_attack()
	player.sprite.play("attack_heavy")
	attack_duration = GameConstants.HEAVY_ATTACK_DURATION
	hitbox_enabled = false
	
	# Stop movement during heavy attack wind-up
	player.velocity.x = 0


func exit() -> void:
	super.exit()
	player.end_attack()


func physics_update(delta: float) -> void:
	attack_duration -= delta
	
	# Enable hitbox during active frames
	var elapsed = GameConstants.HEAVY_ATTACK_DURATION - attack_duration
	if elapsed >= HITBOX_START_FRAME and elapsed < HITBOX_END_FRAME and not hitbox_enabled:
		player.enable_hitbox()
		hitbox_enabled = true
		# Lunge forward
		player.velocity.x = player.facing_direction * 150
	elif elapsed >= HITBOX_END_FRAME and hitbox_enabled:
		player.disable_hitbox()
		hitbox_enabled = false
	
	# Deceleration
	player.velocity.x = move_toward(player.velocity.x, 0, 400 * delta)
	
	# End attack
	if attack_duration <= 0:
		if player.is_on_floor():
			state_machine.change_state(&"Idle")
		else:
			state_machine.change_state(&"Fall")


func handle_input(event: InputEvent) -> void:
	# Heavy attack cannot be canceled or combo'd
	pass
