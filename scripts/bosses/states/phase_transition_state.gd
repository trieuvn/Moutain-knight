# Boss Phase Transition State
extends State

@onready var boss: BaseBoss = owner
var transition_timer: float = 0.0
const TRANSITION_DURATION: float = 2.0


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	boss.sprite.play("phase_transition")
	boss.velocity = Vector2.ZERO
	transition_timer = TRANSITION_DURATION
	
	# Visual effects for phase transition
	_play_transition_effects()


func physics_update(delta: float) -> void:
	transition_timer -= delta
	
	if transition_timer <= 0:
		boss.end_phase_transition()
		state_machine.change_state(&"Idle")


func _play_transition_effects() -> void:
	# Flash and pulse effect
	var tween = boss.create_tween()
	tween.set_loops(4)
	tween.tween_property(boss.sprite, "modulate", Color(1.5, 0.5, 0.5), 0.2)
	tween.tween_property(boss.sprite, "modulate", Color.WHITE, 0.3)
	
	# Screen shake signal
	# EventBus.screen_shake.emit(0.5, 10)


func handle_input(_event: InputEvent) -> void:
	pass
