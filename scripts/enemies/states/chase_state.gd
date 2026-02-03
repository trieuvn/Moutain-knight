# Enemy Chase State
extends State

@onready var enemy: BaseEnemy = owner


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	enemy.sprite.play("run")


func physics_update(delta: float) -> void:
	# Lost target
	if not enemy.is_target_detected():
		state_machine.change_state(&"Idle")
		return
	
	# In attack range
	if enemy.is_target_in_range() and enemy.can_attack:
		state_machine.change_state(&"Attack")
		return
	
	# Chase target
	enemy.move_towards_target()


func handle_input(_event: InputEvent) -> void:
	pass
