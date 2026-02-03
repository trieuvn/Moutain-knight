# Boss Idle State - Waiting for opportunities to attack
extends State

@onready var boss: BaseBoss = owner
var wait_timer: float = 0.0


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	boss.sprite.play("idle")
	wait_timer = randf_range(0.5, 1.5)


func physics_update(delta: float) -> void:
	wait_timer -= delta
	boss.update_facing()
	boss.stop_movement()
	
	if wait_timer <= 0 and not boss.is_attacking:
		# Choose next action based on distance
		var distance = boss.get_distance_to_target()
		
		if distance > 150:
			state_machine.change_state(&"Approach")
		else:
			# Start attack sequence
			var attack = boss.get_next_attack()
			if not attack.is_empty():
				state_machine.change_state(&"Attack", {"attack_data": attack})
			else:
				wait_timer = 0.5


func handle_input(_event: InputEvent) -> void:
	pass
