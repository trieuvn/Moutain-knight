# Enemy Hurt State
extends State

@onready var enemy: BaseEnemy = owner
var stagger_timer: float = 0.0
const STAGGER_DURATION: float = 0.4


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	enemy.sprite.play("hurt")
	stagger_timer = STAGGER_DURATION
	
	# Cancel any ongoing attack
	enemy.is_attacking = false
	enemy.disable_hitbox()


func physics_update(delta: float) -> void:
	stagger_timer -= delta
	
	# Decelerate from knockback
	enemy.velocity.x = move_toward(enemy.velocity.x, 0, 400 * delta)
	
	if stagger_timer <= 0:
		if enemy.is_target_detected():
			state_machine.change_state(&"Chase")
		else:
			state_machine.change_state(&"Idle")


func handle_input(_event: InputEvent) -> void:
	pass
