# Enemy Idle State
extends State

@onready var enemy: BaseEnemy = owner
var idle_time: float = 0.0
@export var max_idle_time: float = 2.0


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	enemy.sprite.play("idle")
	idle_time = randf_range(1.0, max_idle_time)


func physics_update(delta: float) -> void:
	idle_time -= delta
	enemy.stop_movement()
	
	# Check for player detection
	if enemy.is_target_detected():
		state_machine.change_state(&"Chase")
		return
	
	# Random patrol
	if idle_time <= 0:
		state_machine.change_state(&"Patrol")


func handle_input(_event: InputEvent) -> void:
	pass
