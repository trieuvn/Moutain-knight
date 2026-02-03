# Boss Approach State - Moving towards player
extends State

@onready var boss: BaseBoss = owner
@export var approach_speed: float = 120.0


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	boss.sprite.play("walk")


func physics_update(delta: float) -> void:
	var distance = boss.get_distance_to_target()
	
	# Close enough to attack
	if distance <= 100:
		state_machine.change_state(&"Idle")
		return
	
	# Move towards target
	boss.move_towards_target(approach_speed)


func handle_input(_event: InputEvent) -> void:
	pass
