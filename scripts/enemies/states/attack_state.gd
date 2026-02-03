# Enemy Attack State
extends State

@onready var enemy: BaseEnemy = owner
var attack_duration: float = 0.0
var hitbox_enabled: bool = false
const HITBOX_START: float = 0.3
const HITBOX_END: float = 0.5
const ATTACK_DURATION: float = 0.8


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	enemy.sprite.play("attack")
	enemy.start_attack()
	attack_duration = ATTACK_DURATION
	hitbox_enabled = false
	
	# Face target
	enemy.update_facing(enemy.get_direction_to_target())
	
	# Stop movement during attack
	enemy.velocity.x = 0


func exit() -> void:
	super.exit()
	enemy.end_attack()


func physics_update(delta: float) -> void:
	attack_duration -= delta
	
	# Enable hitbox during active frames
	var elapsed = ATTACK_DURATION - attack_duration
	if elapsed >= HITBOX_START and elapsed < HITBOX_END and not hitbox_enabled:
		enemy.enable_hitbox()
		hitbox_enabled = true
		# Lunge forward
		enemy.velocity.x = enemy.facing_direction * 80
	elif elapsed >= HITBOX_END and hitbox_enabled:
		enemy.disable_hitbox()
		hitbox_enabled = false
	
	# Decelerate
	enemy.velocity.x = move_toward(enemy.velocity.x, 0, 300 * delta)
	
	# End attack
	if attack_duration <= 0:
		if enemy.is_target_detected():
			state_machine.change_state(&"Chase")
		else:
			state_machine.change_state(&"Idle")


func handle_input(_event: InputEvent) -> void:
	pass
