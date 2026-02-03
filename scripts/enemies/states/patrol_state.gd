# Enemy Patrol State
extends State

@onready var enemy: BaseEnemy = owner
var patrol_direction: int = 1
var patrol_distance: float = 0.0
var start_position: Vector2


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	enemy.sprite.play("walk")
	
	# Random patrol direction and distance
	patrol_direction = [-1, 1].pick_random()
	patrol_distance = randf_range(50.0, 150.0)
	start_position = enemy.global_position


func physics_update(delta: float) -> void:
	# Check for player
	if enemy.is_target_detected():
		state_machine.change_state(&"Chase")
		return
	
	# Move in patrol direction
	enemy.velocity.x = patrol_direction * enemy.move_speed * 0.5
	enemy.update_facing(patrol_direction)
	
	# Check if reached patrol distance
	if abs(enemy.global_position.x - start_position.x) >= patrol_distance:
		state_machine.change_state(&"Idle")
	
	# Check for walls
	if enemy.is_on_wall():
		state_machine.change_state(&"Idle")


func handle_input(_event: InputEvent) -> void:
	pass
